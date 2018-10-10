class CreateKnowledgeItems < ActiveRecord::Migration[5.2]
  def change
    create_table :knowledge_items do |t|
      t.references :domain, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :kind
      t.integer :time_needed

      t.timestamps
    end
  end
end
