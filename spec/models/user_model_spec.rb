require 'rails_helper'
require 'jwt'

RSpec.describe "Users", type: :model do
  before do
    @user = FactoryBot.create(:user)
  end

  it "is valid with valid attributes" do
    expect(@user).to be_valid
  end

  it "is not valid without a name" do
    @user.name = nil
    expect(@user).not_to be_valid
  end

  it "is not valid without an email" do
    @user.email = nil
    expect(@user).not_to be_valid
  end

  it "is not valid without a password" do
    @user.password = nil
    expect(@user).not_to be_valid
  end

  describe "#total_blogs" do
    it "returns the correct count of blogs" do
      # FactoryBot.create_list(:blog, 3, user: FactoryBot.create(:user))
      FactoryBot.create(:blog, user: @user)
      expect(@user.total_blogs).to eq(1)
    end
  end

  describe "#total_comments" do
    it "returns the correct count of comments" do
      blog = FactoryBot.create(:blog, user: FactoryBot.create(:user))
      FactoryBot.create_list(:comment, 5, user: @user, blog: blog)
      expect(@user.total_comments).to eq(5)
    end
  end

  describe "#total_likes" do
    it "returns the correct count of likes" do
      blog = FactoryBot.create(:blog, user: FactoryBot.create(:user))
      # FactoryBot.create_list(:like, 4, user: @user, blog: blog)
      FactoryBot.create(:like, user: @user, blog: blog)
      expect(@user.total_likes).to eq(1)
    end
  end

  describe "#generate_jwt" do
    it "returns a valid JWT token" do
      token = @user.generate_jwt
      decoded_token = JWT.decode(token, "tempjwtsalt", true, algorithm: "HS256").first

      expect(decoded_token["id"]).to eq(@user.id)
      expect(decoded_token["email"]).to eq(@user.email)
      expect(decoded_token["exp"]).to be > Time.now.to_i
    end
  end
end
