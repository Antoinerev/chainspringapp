class Domain < ApplicationRecord
  include ActiveModel::Serializers::JSON

  has_many :knowledge_items

  def attributes
    {
      name: nil,
      knowledge_items: nil
    }
  end
end
