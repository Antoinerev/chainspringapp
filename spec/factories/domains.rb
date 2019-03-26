FactoryBot.define do
  factory :domain do
    name { "Cooking recipes" }
  end
  factory :topic, class: Domain do
    name { "Startups" }
  end
end
