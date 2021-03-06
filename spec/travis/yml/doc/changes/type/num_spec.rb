describe Travis::Yml::Doc::Change::Scalar do
  subject { described_class.new(build_schema(schema), build_value(value)).apply }

  let(:schema) { { type: :number } }

  describe 'given a str with a number' do
    let(:value) { '1' }
    it { should serialize_to 1 }
  end

  describe 'given a str' do
    let(:value) { 'str' }
    it { should serialize_to value }
  end

  describe 'given a num' do
    let(:value) { 1 }
    it { should serialize_to 1 }
  end

  describe 'given a bool' do
    let(:value) { true }
    it { should serialize_to value }
  end

  describe 'given an array of strs with numbers' do
    let(:value) { ['1'] }
    it { should serialize_to 1 }
  end

  describe 'given an array of strs' do
    let(:value) { ['str'] }
    it { should serialize_to 'str' }
  end

  describe 'given an array of nums' do
    let(:value) { [1] }
    it { should serialize_to 1 }
  end

  describe 'given an object' do
    let(:value) { { foo: 'bar' } }
    it { should serialize_to value }
  end
end
