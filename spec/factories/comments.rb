FactoryBot.define do
  factory :comment do
    content { "Test Comment" }
    association :user
    association :blog
  end
end
