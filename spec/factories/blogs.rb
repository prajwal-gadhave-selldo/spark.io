FactoryBot.define do
  factory :blog do
    title { "Test Blog" }
    content { "Blog content" }
    association :user
  end
end
