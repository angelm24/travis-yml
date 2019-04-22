describe Travis::Yml, 'deploy' do
  let(:opts) { {} }

  subject { described_class.apply(parse(yaml), opts) }

  describe 'given true' do
    yaml %(
      deploy: true
    )
    it { should serialize_to empty }
    it { should have_msg [:error, :deploy, :invalid_type, expected: :seq, actual: :bool, value: true] }
  end

  describe 'given nil' do
    yaml %(
      deploy:
    )
    it { should serialize_to empty }
    it { should have_msg([:warn, :deploy, :empty]) }
  end

  describe 'given a string' do
    yaml %(
      deploy: heroku
    )
    it { should serialize_to deploy: [provider: 'heroku'] }
    it { should_not have_msg }
  end

  describe 'given a map' do
    yaml %(
      deploy:
        provider: heroku
    )
    it { should serialize_to deploy: [provider: 'heroku'] }
    it { should_not have_msg }
  end

  describe 'unknown provider' do
    yaml %(
      deploy:
        - provider: unknown
    )
    it { should serialize_to empty }
    it { should have_msg [:error, :'deploy.provider', :unknown_value, value: 'unknown'] }
  end

  describe 'invalid type on provider' do
    yaml %(
      deploy:
        provider:
          provider: heroku
    )
    it { should serialize_to empty }
    it { should have_msg [:error, :deploy, :invalid_type, expected: :seq, actual: :map, value: { provider: { provider: 'heroku' } }] }
  end

  describe 'given a map' do
    describe 'without a provider' do
      let(:opts) { { required: true, defaults: true } }
      yaml %(
        deploy:
          foo: foo
      )
      it { should serialize_to language: 'ruby', os: ['linux'] }
      it { should have_msg [:error, :deploy, :required, key: :provider] }
    end

    describe 'with a provider' do
      yaml %(
        deploy:
          provider: heroku
      )
      it { should serialize_to deploy: [provider: 'heroku'] }
    end

    # TODO check if we really need :heroku to be non-strict
    describe 'with extra data (string)' do
      yaml %(
        deploy:
          provider: heroku
          foo: foo
      )
      it { should serialize_to deploy: [provider: 'heroku', foo: 'foo'] }
    end

    describe 'with extra data (map)' do
      yaml %(
        deploy:
          provider: heroku
          foo:
            bar: baz
      )
      it { should serialize_to deploy: [provider: 'heroku', foo: { bar: 'baz' }] }
    end

    describe 'with a secure string' do
      yaml %(
        deploy:
          provider: heroku
          api_key:
            secure: secure
      )
      it { should serialize_to deploy: [provider: 'heroku', api_key: { secure: 'secure' }] }
    end
  end

  describe 'given a seq' do
    describe 'with a provider' do
      yaml %(
        deploy:
          - provider: heroku
          - provider: s3
      )
      it { should serialize_to deploy: [{ provider: 'heroku' }, { provider: 's3' } ] }
    end

    describe 'with extra data (string)' do
      yaml %(
        deploy:
          - provider: heroku
            foo: bar
      )
      it { should serialize_to deploy: [{ provider: 'heroku', foo: 'bar' }] }
    end

    describe 'with extra data (map)' do
      yaml %(
        deploy:
          - provider: heroku
            foo:
              bar: baz
      )
      it { should serialize_to deploy: [{ provider: 'heroku', foo: { bar: 'baz' } }] }
    end

    describe 'with a secure string' do
      yaml %(
        deploy:
          - provider: heroku
            api_key:
              secure: secure
      )
      it { should serialize_to deploy: [provider: 'heroku', api_key: { secure: 'secure' }] }
    end
  end

  describe 'conditions' do
    describe 'given a string' do
      yaml %(
        deploy:
          provider: heroku
          on: master
      )
      it { should serialize_to deploy: [provider: 'heroku', on: { branch: ['master'] }] }
    end

    describe 'given a map' do
      describe 'repo' do
        yaml %(
          deploy:
            provider: heroku
            on:
              repo: foo/bar
        )
        it { should serialize_to deploy: [provider: 'heroku', on: { repo: 'foo/bar' }] }
      end

      describe 'branch' do
        yaml %(
          deploy:
            provider: heroku
            on:
              branch: master
        )
        it { should serialize_to deploy: [provider: 'heroku', on: { branch: ['master'] }] }
      end

      describe 'all_branches' do
        yaml %(
          deploy:
            provider: heroku
            on:
              all_branches: true
        )
        it { should serialize_to deploy: [provider: 'heroku', on: { all_branches: true }] }
      end

      describe 'language specific key' do
        yaml %(
          deploy:
            provider: heroku
            on:
              rvm: 2.3.1
        )
        it { should serialize_to deploy: [provider: 'heroku', on: { rvm: ['2.3.1'] }] }
      end

      describe 'language specific setting (with an alias)' do
        yaml %(
          deploy:
            provider: heroku
            on:
              ruby: 2.3.1
        )
        it { should serialize_to deploy: [provider: 'heroku', on: { rvm: ['2.3.1'] }] }
      end
    end

    describe 'branch specific option hashes (holy shit. example for a valid hash from travis-build)' do
      yaml %(
        deploy:
          - provider: heroku
            on:
              branch:
                production:
                  bucket: production_branch
      )
      it { should serialize_to deploy: [provider: 'heroku', on: { branch: { production: { bucket: 'production_branch' } } }] }
      it { should have_msg [:warn, :'deploy.on.branch', :deprecated, deprecation: :branch_specific_option_hash] }
    end

    # kinda hard to support if we want strict structure on deploy keys
    describe 'option specific branch hashes (deprecated, according to travis-build)' do
      yaml %(
        deploy:
          - provider: heroku
            run:
              production: production
      )
      xit { should serialize_to deploy: [provider: 'heroku', run: { production: 'production' }] }
      xit { should have_msg [:warn, :'deploy.run', :deprecated, given: :run, info: :branch_specific_option_hash] }
    end

    describe 'migrating :tags, with :tags already given', v2: true, migrate: true do
      yaml %(
        deploy:
          provider: releases
          tags: true
          on:
            tags: true
      )
      # not possible because deploy is not strict?
      it { should have_msg [:warn, :deploy, :migrate, key: :tags, to: :on, value: true] }
    end
  end

  describe 'allow_failure' do
    yaml %(
      deploy:
        provider: heroku
        allow_failure: true
    )
    it { should serialize_to deploy: [provider: 'heroku', allow_failure: true] }
  end

  describe 'app and condition' do
    yaml %(
      deploy:
        - provider: heroku
          app:
            master: production
            dev: staging
          on: master
    )
    it { should serialize_to deploy: [provider: 'heroku', app: { master: 'production', dev: 'staging' }, on: { branch: ['master'] }] }
    it { should_not have_msg }
  end

  describe 'edge' do
    describe 'given a bool' do
      yaml %(
        deploy:
          provider: heroku
          edge: true
      )
      # this used to be edge: true, but we now aim at one single, normal form
      # downstream code will probably be happy with this anyway, but we should
      # check travis-build and dpl
      it { should serialize_to deploy: [provider: 'heroku', edge: { enabled: true }] }
      it { should have_msg [:info, :'deploy.edge', :edge] }
    end

    describe 'given a map' do
      yaml %(
        deploy:
          provider: herou
          edge:
            source: source
            branch: branch
      )
      it { should serialize_to deploy: [provider: 'heroku', edge: { source: 'source', branch: 'branch' }] }
    end
  end

  describe 'misplaced keys', v2: true, migrate: true do
    yaml %(
      deploy:
        edge: true
        provider: heroku
        api_key: api_key
    )
    it { should serialize_to deploy: [provider: 'heroku', edge: true, api_key: 'api_key'] }
    it { should have_msg [:warn, :root, :migrate, key: :provider, to: :deploy, value: 'heroku'] }
    it { should have_msg [:warn, :root, :migrate, key: :api_key, to: :deploy, value: 'api_key'] }
  end

  describe 'misplaced keys (2)', v2: true, migrate: true do
    yaml %(
      deploy:
        edge: true
      provider: heroku
      api_key: api_key
    )
    it { should serialize_to deploy: [provider: 'heroku', edge: true, api_key: 'api_key'] }
    it { should have_msg [:warn, :root, :migrate, key: :provider, to: :deploy, value: 'heroku'] }
    it { should have_msg [:warn, :root, :migrate, key: :api_key, to: :deploy, value: 'api_key'] }
  end

  describe 'misplaced key that would result in an invalid node if migrated' do
    yaml %(
      file: file
    )
    it { should serialize_to file: 'file' }
    it { should have_msg [:warn, :root, :misplaced_key, key: :file, value: 'file'] }
  end
end