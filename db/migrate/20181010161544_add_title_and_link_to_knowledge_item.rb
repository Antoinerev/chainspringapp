class AddTitleAndLinkToKnowledgeItem < ActiveRecord::Migration[5.2]
  def change
    add_column :knowledge_items, :title, :string
    add_column :knowledge_items, :link, :string
  end
end
