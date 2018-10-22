class User < ApplicationRecord
  include ActiveModel::Serializers::JSON

  has_many :knowledge_items
  has_many :domains, through: :knowledge_items

  def attributes
    {
      name: nil,
      domains_list: nil,
      unique_domains: nil,
      knowledge_items_titles: nil,
      map_data: nil
    }
  end

  def domains_list
    self.domains.distinct.pluck(:name)
  end
  def unique_domains
    self.domains.uniq
  end
  def knowledge_items_titles
    self.knowledge_items.pluck(:title).compact
  end
  def map_data
    user_map = Map.create(self)
  end

end
