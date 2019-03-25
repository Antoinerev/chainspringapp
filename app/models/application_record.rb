class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def ascendants_type
    self.ascendants ? self.ascendants.first.class.to_s : nil
  end
  def descendants_type
    self.descendants ? self.descendants.first.class.to_s : nil
  end
  def capitalize(attribute)
    if self.send(attribute).present?
      capitalized_attribute = self.send(attribute).split(" ").map(&:capitalize).join(" ").strip
      self[attribute] = capitalized_attribute
    end
  end
end
