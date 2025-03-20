require 'rails_helper'

RSpec.describe Blog, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @blog = FactoryBot.create(:blog, user: @user)
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

  describe "#liked_by?" do
    before do
      @other_user = FactoryBot.create(:user, email: "prajwal@gmail.com")
    end

    it "returns true if the blog is liked by the user" do
      FactoryBot.create(:like, user: @other_user, blog: @blog)
      expect(@blog.liked_by?(@other_user)).to be true
    end

    it "returns false if the blog is not liked by the user" do
      expect(@blog.liked_by?(@other_user)).to be false
    end
  end
end
