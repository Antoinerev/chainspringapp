class KnowledgeItemDomain < ApplicationRecord
  belongs_to :knowledge_item
  belongs_to :domain
end
