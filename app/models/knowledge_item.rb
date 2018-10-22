class KnowledgeItem < ApplicationRecord
  include ActiveModel::Serializers::JSON

  belongs_to :domain

  enum kind: {undefined: 0, book: 1, online_text: 2, online_video: 3, mobile_app: 4, place: 5, website: 6}

  # def attributes

  # end
end
