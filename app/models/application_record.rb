class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def ascendants_type
    self.ascendants ? self.ascendants.first.class.to_s : nil
  end
  def descendants_type
    self.descendants ? self.descendants.first.class.to_s : nil
  end
  def capitalize(attribute)
    capitalized_attribute = self.send(attribute).split(" ").map(&:capitalize).join(" ")

    self.update({attribute => capitalized_attribute}) unless self.send(attribute) == capitalized_attribute
  end
end
