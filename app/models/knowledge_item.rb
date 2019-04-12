class KnowledgeItem < ApplicationRecord
  include ActiveModel::Serializers::JSON

  belongs_to :user
  has_many :knowledge_item_domains
  has_many :domains, through: :knowledge_item_domains

  enum kind: {undefined: 0, book: 1, online_text: 2, online_video: 3, mobile_app: 4, place: 5, website: 6}

  after_initialize ->{capitalize_all('title')}

  def attributes
    {
      map_id: nil,
      name: nil,
      object_type: nil,
      domain_names: nil,
      "_color"=> nil,
      kind: nil,
      time_needed: nil,
      link: nil,
      topics: nil
      # ascendants: nil,
      # ascendants_type: nil,
      # descendants: nil,
      # descendants_type: nil
    }
  end

  def name
    title
  end
  def type
    self.class.to_s
  end
  def object_type
    type
  end
  def ascendants
    domains
  end
  def descendants
    nil
  end
  def domain_names
    domains.distinct.pluck(:name).to_sentence
  end
  def topics
    domain_names
  end
  def domains_list
    domains.uniq
  end
  def map_id
    "k_#{id}"
  end
  def links
    domains = domains_list.map.with_index{|domain, i| {id: "kl_#{i}", sid: domain.map_id, tid: self.map_id}}
  end
  def _color
    '#42c4ef'
  end
end
