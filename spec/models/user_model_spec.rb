require 'rails_helper'

RSpec.describe User, type: :model do
  # let(:user) { FactoryBot.create(:user) }
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
end
