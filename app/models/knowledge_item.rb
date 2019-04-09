class KnowledgeItem < ApplicationRecord
  include ActiveModel::Serializers::JSON

  belongs_to :user
  has_many :knowledge_item_domains
  has_many :domains, through: :knowledge_item_domains

  enum kind: {undefined: 0, book: 1, online_text: 2, online_video: 3, mobile_app: 4, place: 5, website: 6}

  after_initialize ->{capitalize_all('title')}

  def attributes
    {
      id: nil,
      name: nil,
      type: nil,
      domain_names: nil
      # ascendants: nil,
      # ascendants_type: nil,
      # descendants: nil,
      # descendants_type: nil
    }
  end

  def name
    self.title
  end
  def type
    self.class.to_s
  end
  def ascendants
    self.domains
  end
  def descendants
    nil
  end
  def domain_names
    self.domains.distinct.pluck(:name).to_sentence
  end
end
