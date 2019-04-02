class User < ApplicationRecord
  include ActiveModel::Serializers::JSON
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :knowledge_items
  has_many :domains, through: :knowledge_items

  def attributes
    {
      id: nil,
      name: nil,
      type: nil,
      ascendants: nil,
      ascendants_type: nil
      # descendants: nil,
      # descendants_type: nil,
      # domains_list: nil
    }
  end
  def kis
    self.knowledge_items
  end
  def domains_list
    self.domains.distinct.pluck(:name)
  end
  def type
    self.class.to_s
  end
  def ascendants
    # group
    nil
  end
  def descendants
    self.domains.uniq
  end
end
