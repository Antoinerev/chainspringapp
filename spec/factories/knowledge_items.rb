FactoryBot.define do
  factory :reference, class: KnowledgeItem do
    user
    title { "The best reference" }
    # knowledge_item_domain
  end
end
