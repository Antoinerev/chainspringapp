FactoryBot.define do
  factory :domain do
    name { "Cooking recipes" }
  end
  factory :topic, class: Domain do
    name { "Startups" }
  end
  factory :topic2, class: Domain do
    name { "growth hacking" }
  end
  factory :topic_without_ref, class: Domain do
    name { "unref topic" }
  end
end
