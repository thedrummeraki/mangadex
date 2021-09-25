RSpec.describe Mangadex::Internal::WithAttributes do
  # We need to use Mangadex::MangadexObject to have a few easy to
  # use constructor.
  class Dummy < Mangadex::MangadexObject
    include Mangadex::Internal::WithAttributes

    has_attributes :a, :b, :c, :d
  end

  describe '#from_data' do
    it 'sets specified attributes' do
      result = Dummy.from_data({
        attributes: {
          a: 'one',
          c: 'two',
        },
      })

      expect(result.attributes.a).to eq('one')
      expect(result.attributes.c).to eq('two')
      expect(result.attributes.b).to be_nil
      expect(result.attributes.d).to be_nil
    end

    it 'creates the special attribute class' do
      result = Dummy.from_data({
        attributes: {
          a: 'one',
          c: 'two',
        },
      })

      expect { Object.const_get('Dummy_Attributes') }.not_to raise_error
      expect(result.attributes.class).to eq(Dummy_Attributes)
    end

    it 'adds relationships as needed' do
      result = Dummy.from_data({
        attributes: {
          a: 'one',
          c: 'two',
        },
        relationships: [
          {
            id: 'rel-1',
            type: 'pet',
            attributes: { name: 'doggy', age: 3 },
          },
          {
            id: 'rel-2',
            type: 'pet',
            attributes: { name: 'neko', age: 4 },
          },
          {
            id: 'rel-3',
            type: 'avatar',
            attributes: { url: 'https://dummy.io/profile.png' },
          },
        ],
      })

      expect(result.relationships.count).to eq(3)
      expect(result.pets.count).to eq(2)
      expect(result.pet.attributes['name']).to eq('doggy')
      expect(result.pet.attributes['age']).to eq(3)
      expect(result.avatars.count).to eq(1)
      expect(result.avatar.attributes['url']).to eq('https://dummy.io/profile.png')
    end
  end

  describe 'attr_accessor' do
    let(:dummy_object) do
      Dummy.from_data({
        attributes: {
          a: 'and',
          b: 'another',
          c: 'one',
          d: true,
        },
      })
    end

    it 'sets reader' do
      expect(dummy_object.attributes).to respond_to(:a)
      expect(dummy_object.attributes).to respond_to(:b)
      expect(dummy_object.attributes).to respond_to(:c)
      expect(dummy_object.attributes).to respond_to(:d)
    end

    it 'sets writer' do
      expect(dummy_object.attributes).to respond_to(:a=)
      expect(dummy_object.attributes).to respond_to(:b=)
      expect(dummy_object.attributes).to respond_to(:c=)
      expect(dummy_object.attributes).to respond_to(:d=)
    end
  end
end
