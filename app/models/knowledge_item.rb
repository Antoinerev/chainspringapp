class KnowledgeItem < ApplicationRecord
  include ActiveModel::Serializers::JSON

  belongs_to :domain
  belongs_to :user

  enum kind: {undefined: 0, book: 1, online_text: 2, online_video: 3, mobile_app: 4, place: 5, website: 6}

  def attributes
    {
      name: nil,
      type: nil,
      ascendants: nil,
      ascendants_type: nil,
      descendants: nil,
      descendants_type: nil
    }
  end

  def name
    self.title
  end
  def type
    self.class.to_s
  end
  def ascendants
    [self.domain]
  end
  def descendants
    nil
  end
end
