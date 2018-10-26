class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def ascendants_type
    self.ascendants ? self.ascendants.first.class.to_s : nil
  end
  def descendants_type
    self.descendants ? self.descendants.first.class.to_s : nil
  end
end
