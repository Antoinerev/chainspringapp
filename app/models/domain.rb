class Domain < ApplicationRecord
  include ActiveModel::Serializers::JSON

  has_many :knowledge_items
  has_many :users, through: :knowledge_items

  def attributes
    {
      id: nil,
      name: nil,
      type: nil,
      ascendants: nil,
      ascendants_type: nil,
      descendants: nil,
      descendants_type: nil,
      knowledge_items: nil
    }
  end

  def type
    self.class.to_s
  end
  def ascendants
    self.users.uniq
  end
  def descendants
    self.knowledge_items.uniq
  end
end
