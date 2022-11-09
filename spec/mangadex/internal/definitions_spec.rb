# typed: ignore

RSpec.describe Mangadex::Internal::Definition do
  class DummyDefinition
    attr_accessor :value
    def initialize(value)
      @value = value
    end

    def to_s
      "(dummy-#{value})"
    end
  end

  it "validates required arguments" do
    args = { a: 1, b: '2', c: [:three, :four] }
    result = Mangadex::Internal::Definition.validate(args, {
      a: { accepts: Integer, required: true },
      b: { accepts: String, required: true },
      c: { accepts: [Symbol], required: true },
    })

    expect(result).to eq(args)
  end

  it "validates non-required arguments" do
    args = { a: 1, b: '2' }
    result = Mangadex::Internal::Definition.validate(args, {
      a: { accepts: Integer, required: true },
      b: { accepts: String, required: true },
      c: { accepts: [Symbol] },
    })

    expect(result).to eq(args)
  end

  it "fails validation when missing required arguments" do
    args = { a: 1, b: '2', c: [:three, :four] }

    expect do
      Mangadex::Internal::Definition.validate(args, {
        a: { accepts: Integer, required: true },
        b: { accepts: String, required: true },
        c: { accepts: [Symbol], required: true },
        d: { accepts: ['something'], required: true },
      })
    end.to raise_error(ArgumentError, /Missing :d/)
  end

  it "fails validation when unknown arguments are passed in" do
    args = { a: 1, b: '2', c: [:three, :four], d: 'something' }

    expect do
      Mangadex::Internal::Definition.validate(args, {
        a: { accepts: Integer, required: true },
        b: { accepts: String, required: true },
        c: { accepts: [Symbol], required: true },
      })
    end.to raise_error(ArgumentError, /params\[:d\] does not exist/)
  end

  it "validates regex arguments" do
    args = { a: "I am valid Regex!", b: "I am a valid Regex" }
    regexp = /[I am (a)? valid Regex(\.)?]/

    result = Mangadex::Internal::Definition.validate(args, {
      a: { accepts: regexp },
      b: { accepts: regexp },
    })

    expect(result).to eq(args)
  end

  it "validates amongst accepted values" do
    args = { a: ["one", "two"] }

    result = Mangadex::Internal::Definition.validate(args, {
      a: { accepts: ["one", "two"] },
    })

    expect(result).to eq(args)
  end

  it "fails validation with invalid value" do
    args = { a: ["twos"] }

    expect do
      Mangadex::Internal::Definition.validate(args, {
        a: { accepts: ["one", "two"] },
      })
    end.to raise_error(ArgumentError, /Expected elements in :a to be one of \["one", "two"\], but found \["twos"\]/)
  end

  it "validates list of items" do
    args = { a: ["one", "two"], b: [1, 2], c: [DummyDefinition.new(1), DummyDefinition.new(2)] }

    result = Mangadex::Internal::Definition.validate(args, {
      a: { accepts: [String] },
      b: { accepts: [Integer] },
      c: { accepts: [DummyDefinition] },
    })

    expect(result).to eq(args)
  end

  it "fails validation with invalid type detected" do
    args = { a: [DummyDefinition.new(1)] }

    expect do
      Mangadex::Internal::Definition.validate(args, {
        a: { accepts: [String] },
      })
    end.to raise_error(ArgumentError, /Expected elements in :a to be an Array of String, but found \[\"\<\(dummy\-\d+\)\:DummyDefinition\>/)
  end

  it "converts to array" do
    args = { a: "one" }

    result = Mangadex::Internal::Definition.validate(args, {
      a: { accepts: [String], converts: :to_a },
    })

    expect(result).to eq({ a: ["one"] })
  end

  it "converts to integer" do
    args = { a: "1", b: :"2", c: 3 }

    result = Mangadex::Internal::Definition.validate(args, {
      a: { accepts: Integer, converts: :to_i },
      b: { accepts: Integer, converts: :to_i },
      c: { accepts: Integer, converts: :to_i },
    })

    expect(result).to eq({ a: 1, b: 2, c: 3 })

    expect do
      args = { a: "hehe" }
      Mangadex::Internal::Definition.validate(args, {
        a: { accepts: Integer, converts: :to_i },
      })
    end.to raise_error(ArgumentError, /Proc parsing error: invalid value for Integer\(\)\: \"hehe\"/)
  end
end