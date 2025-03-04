require 'rails_helper'

RSpec.describe Blog, type: :model do
  # let(:blog) { FactoryBot.create(:blog) }
  before do
    @blog = FactoryBot.create(:blog)
  end

  it "is valid with valid attributes" do
    expect(@blog).to be_valid
  end

  it "is not valid without a title" do
    @blog.title = nil
    expect(@blog).not_to be_valid
  end

  it "is not valid without content" do
    @blog.content = nil
    expect(@blog).not_to be_valid
  end
end
