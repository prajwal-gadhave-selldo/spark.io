FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "test@admin.com" }
    password { "password" }
    role { "user" }
  end
end
