class Domain < ApplicationRecord
  include ActiveModel::Serializers::JSON

  has_many :knowledge_item_domains
  has_many :knowledge_items, through: :knowledge_item_domains
  has_many :users, through: :knowledge_items

  after_initialize ->{capitalize_all('name')}

  validates :name, uniqueness: { case_sensitive: :false }

  def attributes
    {
      map_id: nil,
      name: nil,
      object_type: nil,
      "_color"=> nil
      # ascendants: nil,
      # ascendants_type: nil,
      # descendants: nil,
      # descendants_type: nil,
      # knowledge_items: nil
    }
  end

  def type
    self.class.to_s
  end
  def object_type
    type
  end
  def ascendants
    self.users.uniq
  end
  def descendants
    self.knowledge_items.uniq
  end
  def map_id
    "d_#{self.id}"
  end
  def _color
    "#fc770a"
  end
  def kis_list
    super
  end
  def users_list
    users.collect(&:node)
  end
  def links
    domain_to_kis = descendants.map.with_index{|ki, i| {id: "dkl_#{i}", sid: self.map_id, tid: ki.map_id}}
    domain_to_users = ascendants.map.with_index{|user, i| {id: "dul_#{i}", sid: user.map_id, tid: self.map_id}}
    return domain_to_kis + domain_to_users
  end
end
