class KnowledgeMap
  attr_accessor :user, :nodes, :links

  def initialize(node_object)
    @node_object = node_object
  end

  def d3_network_initialize
  end
  def build_v1
    @depth_level = 3
    user_map = d3_network_map_building
    user_map[:nodesize] = 50
    user_map[:build_version] = "v1"
    return user_map
  end
  def build_v2
    @depth_level = 2
    user_map = d3_network_map_building
    user_map[:nodesize] = 50
    user_map[:build_version] = "v2"
    return user_map
  end
  def build_v3
    @depth_level = 3
    user_map = d3_network_map_building
    user_map[:nodesize] = 75
    user_map[:build_version] = "v3"
    return user_map
  end
  def d3_network_map_building
    @nodes_objects = []
    @nodes = []
    @links = []
    @id = 1

    if @node_object
      # creates map node from object instance
      @node = build_node(@node_object)
      @nodes << @node
      # keeps track of allready processed instances
      @nodes_objects << @node_object

      # gets additional ascendant instances and keeps track of them
      new_nodes_objects = @node_object.ascendants.present? ? @node_object.ascendants - @nodes_objects : []
      create_nodes(new_nodes_objects, 'ascendants')

      # gets additional descendant instances and keeps track of them
      new_nodes_objects = @node_object.descendants.present? ? @node_object.descendants - @nodes_objects : []
      create_nodes(new_nodes_objects)

      new_nodes_objects = get_linked_users(@node_object).present? ? get_linked_users(@node_object) - @nodes_objects : []
      create_linked_users_nodes(new_nodes_objects, @node_object)

      return {name: @node_object.name, nodes: @nodes, links: @links, allKinds: KnowledgeItem.kinds.keys}
    else
      return {name: "", nodes: @nodes, links: @links, message: "no record found"}
    end
  end

  private
  def build_node(node_object)
    if node_object.type == "KnowledgeItem"
      # details in addition to basic node
      return Node.new(id: node_object.id, type: node_object.type, name: node_object.name, kind: kind_from(node_object), _color: colors(:node, node_key(node_object)),
          link: link_from(node_object), time_needed: node_object.time_needed)
    else
      # Basic node
      return Node.new(id: node_object.id, type: node_object.type, name: node_object.name, _color: colors(:node, node_key(node_object)))
    end
  end
  def create_linked_users_nodes(new_nodes_objects, node_of_origin)
    if new_nodes_objects.present?
      new_nodes_objects.each do |linked_user|
        linked_user_node = build_node(linked_user)
        link = { sid: node_of_origin.id, tid: linked_user_node.id, _color: colors(:link, :secondary) }
        @nodes << linked_user_node
        @links << link
      end
      @nodes_objects += new_nodes_objects
    end
  end

  def create_nodes(new_nodes_objects, data_type = 'descendants')
    if new_nodes_objects.present?
      new_nodes_objects.each do |node_object|
        new_node = build_node(node_object)
        link = { sid: @node.id, tid: new_node.id }
        @nodes << new_node
        @links << link

        if @depth_level > 2
          unless data_type == 'ascendants'
            create_descendants_nodes(new_node, node_object)
          end
        end
      end
      @nodes_objects += new_nodes_objects
    end
  end
  def create_descendants_nodes(new_node, node_object)
    new_nodes_objects_desc = node_object.descendants.present? ? node_object.descendants - @nodes_objects : []
    if new_nodes_objects_desc.present?
      new_nodes_objects_desc.each do |descendant2|
        if descendant2.type == 'KnowledgeItem' && descendant2.user == @nodes_objects.first
          node_color = colors(:node, node_key(descendant2))
          link_color = colors(:link, :primary)
        else
          node_color = colors(:node, :secondary)
          link_color = colors(:link, :secondary)
        end
        descendant2_node = Node.new(id: descendant2.id, type: descendant2.type, name: descendant2.name, kind: kind_from(node_object), _color: node_color,
          link: link_from(descendant2))
        link = { sid: new_node.id, tid: descendant2_node.id, _color: link_color }
        @nodes << descendant2_node
        @links << link
      end
      @nodes_objects += new_nodes_objects_desc
    end

    if node_object.type == "Domain"
      new_nodes_objects = node_object.users.uniq - [@node_object]
      create_linked_users_nodes(new_nodes_objects, node_object)
    end
  end
  def node_key(node)
    node.type.underscore.to_sym
  end
  def get_linked_users(node)
    linked_users = []
    if node.type == 'Domain'
      domains = Domain.where(name: node.name)
      users = []
      domains.each{|domain| users += domain.users}
      linked_users = users.uniq
    end
    return linked_users
  end
  def colors(type, key)
    colors = {
      node:
      {
        user: '#26a424',
        linked_user: '#B3D5B2',
        domain: '#fc770a',
        knowledge_item: '#42c4ef',
        secondary: '#B3D5B2'
      },
      link:
      {
        primary: '#87db1c',
        secondary: '#D1D6A1'
      }
    }
    return colors[type.to_sym][key.to_sym]
  end
  def link_from(object)
    if object.methods.include?(:link)
      return object.link
    else
      return ""
    end
  end
  def kind_from(object)
    if object.methods.include?(:kind)
      return object.kind
    else
      return ""
    end
  end
end
