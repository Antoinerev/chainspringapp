FactoryBot.define do
  factory :reference, class: KnowledgeItem do
    user
    title { "The best reference" }
    domain
  end
  # factory :reference, class: KnowledgeItem do
  #   user
  #   title { "The best reference" }
  #   association :domain_id, factory: :topic
  # end
end
