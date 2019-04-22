describe Travis::Yml::Schema::Def::Notification::Slack, 'structure' do
  describe 'definitions' do
    subject { Travis::Yml.schema[:definitions][:notification][:slack] }

    # it { puts JSON.pretty_generate(subject) }

    it do
      should eq(
        '$id': :slack,
        title: 'Slack',
        anyOf: [
          {
            type: :object,
            properties: {
              rooms: {
                '$ref': '#/definitions/secures'
              },
              template: {
                '$ref': '#/definitions/notification/templates'
              },
              enabled: {
                type: :boolean
              },
              disabled: {
                type: :boolean
              },
              on_pull_requests: {
                type: :boolean
              },
              on_success: {
                '$ref': '#/definitions/notification/frequency'
              },
              on_failure: {
                '$ref': '#/definitions/notification/frequency'
              }
            },
            additionalProperties: false,
            normal: true,
            prefix: :rooms,
            changes: [
              {
                change: :enable,
              }
            ]
          },
          {
            '$ref': '#/definitions/secures'
          },
          {
            type: :boolean
          }
        ]
      )
    end
  end

  describe 'schema' do
    subject { described_class.new.schema }

    it do
      should eq(
        '$ref': '#/definitions/notification/slack'
      )
    end
  end
end