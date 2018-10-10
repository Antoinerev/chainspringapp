class KnowledgeItem < ApplicationRecord
  belongs_to :domain
  belongs_to :user

  enum kind: {undefined: 0, book: 1, online_text: 2, online_video: 3}
end
