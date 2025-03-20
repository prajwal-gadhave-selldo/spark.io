FactoryBot.define do
  factory :blog do
    title { Faker::Lorem.sentence }  
    content { "Blog content" }
    association :user
  end
end
