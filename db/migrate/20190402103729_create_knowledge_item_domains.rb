class CreateKnowledgeItemDomains < ActiveRecord::Migration[5.2]
  def change
    create_table :knowledge_item_domains do |t|
      t.references :knowledge_item, foreign_key: true
      t.references :domain, foreign_key: true

      t.timestamps
    end

    KnowledgeItem.all.each do |ki|
      new_ki_domain = KnowledgeItemDomain.create(knowledge_item_id: ki.id, domain_id: ki.domain_id)
    end

    remove_column :knowledge_items, :domain_id, :references, foreign_key: true

  end
end
