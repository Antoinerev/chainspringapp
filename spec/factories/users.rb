FactoryBot.define do
  sequence :email do |n|
    "test#{n}@test.fr"
  end
  factory :user do
    name { "John Doe" }
    email { generate :email }
    password { "123456" }
    password_confirmation { "123456" }
  end
end
