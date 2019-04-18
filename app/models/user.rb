class User < ApplicationRecord
  include ActiveModel::Serializers::JSON
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :knowledge_items, dependent: :destroy
  has_many :domains, through: :knowledge_items

  def attributes
    {
      # map_id: nil,
      name: nil,
      # type: nil,
      # ascendants: nil,
      # ascendants_type: nil,
      # domains_list: nil,
      # kis_list: nil,
      nodes: nil,
      links: nil
      # descendants_type: nil,
      # domain_names: nil
    }
  end
  def kis
    knowledge_items
  end
  def domain_names
    domains.distinct.pluck(:name)
  end
  def type
    self.class.to_s
  end
  def ascendants
    # group
    nil
  end
  def descendants
    domains.uniq
  end
  def domains_list
    descendants.as_json
  end
  def kis_list
    super
  end
  def nodes
    user_node_array = [self.node]
    nodes = user_node_array + domains_list + kis_list
    nodes.each do |node|
      id = node.delete(:map_id)
      node[:id] = id if id
    end
    return nodes
  end
  def node
    {id: self.map_id, name: self.name, object_type: self.type, "_color"=> 'rgb(209,95,0)'}
  end
  def links
    user_to_domains = descendants.map.with_index{|domain, i| {id: "ul_#{i}", sid: self.map_id, tid: domain.map_id}}
    kis_to_domains = kis.collect(&:links).flatten
    return user_to_domains + kis_to_domains
  end
  def map_id
    "u_#{id}"
  end
end
