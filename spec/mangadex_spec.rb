# typed: ignore

RSpec.describe Mangadex do
  it "has a version number" do
    expect(Mangadex::Version::FULL).not_to be nil
  end
end
