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
    user_map[:build_version] = __method__.to_s.split(/_/).last
    return user_map
  end
  def build_v2
    @depth_level = 2
    user_map = d3_network_map_building
    user_map[:nodesize] = 50
    user_map[:build_version] = __method__.to_s.split(/_/).last
    return user_map
  end
  def build_v3
    @depth_level = 3
    user_map = d3_network_map_building
    user_map[:nodesize] = 75
    user_map[:build_version] = __method__.to_s.split(/_/).last
    return user_map
  end
  def build_v4
    @depth_level = 3
    user_map = d3_network_map_building_v2
    user_map[:nodesize] = 75
    user_map[:build_version] = __method__.to_s.split(/_/).last
    return user_map
  end
  def d3_network_map_building_v2
    if @node_object
      if @node_object.type == 'User'
        user_json = @node_object.as_json
        @nodes = user_json[:nodes]
        @links = user_json[:links]
      elsif @node_object.type == 'Domain'
        ki_nodes = @node_object.kis_list.each{|node| node["_color"] = "#89C4D9"}
        user_nodes = @node_object.users_list.each{|node| node["_color"] = "#6BAE35"}
        @nodes = [@node_object.node] + user_nodes + ki_nodes
        @links = @node_object.links
      end
      return {name: @node_object.name, nodes: @nodes, links: @links.uniq, allKinds: KnowledgeItem.kinds.keys}
    else
      return {name: "", nodes: [], links: [], message: "no record found"}
    end
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
      create_linked_users_nodes(new_nodes_objects, @node)

      return {name: @node_object.name, nodes: @nodes, links: @links.uniq, allKinds: KnowledgeItem.kinds.keys}
    else
      return {name: "", nodes: @nodes, links: @links.uniq, message: "no record found"}
    end
  end

  private
  def build_node(node_object, options: {color_key: :primary, link_from: nil})
    color_key = options[:color_key]
    link_from = options[:link_from]
    if color_key == :primary
      node_color = colors(:node, node_key(node_object))
    else
      node_color = colors(:node, color_key)
    end
    if node_object.type == "KnowledgeItem"
      # details in addition to basic node
      link_origin = link_from.present? ? link_from : node_object

      return Node.new(id: node_object.id, type: node_object.type, name: node_object.name, kind: kind_from(node_object), _color: node_color,
          link: link_from(link_origin), time_needed: node_object.time_needed, topics: node_object.domain_names)
    else
      # Basic node
      return Node.new(id: node_object.id, type: node_object.type, name: node_object.name, _color: node_color)
    end
  end
  def create_linked_users_nodes(new_nodes_objects, node_of_origin)
    if new_nodes_objects.present?
      new_nodes_objects.each do |linked_user|
        linked_user_node = build_node(linked_user)
        if node_of_origin.type == "Node"
          link = { sid: node_of_origin.id, tid: linked_user_node.id}
          @nodes << linked_user_node
          @links << link
        end
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
        @nodes_objects << node_object
        if @depth_level > 2
          unless data_type == 'ascendants'
            create_descendants_nodes(new_node, node_object)
          end
        end
      end
    end
  end
  def create_descendants_nodes(new_node, node_object)
    new_nodes_objects_desc = node_object.descendants.present? ? node_object.descendants - @nodes_objects : []
    if new_nodes_objects_desc.present?
      new_nodes_objects_desc.each do |descendant2|
        if descendant2.type == 'KnowledgeItem' && descendant2.user == @nodes_objects.first
          color_key = :primary
        else
          color_key = :secondary
        end
        descendant2_node = build_node(descendant2, options: {color_key: color_key})
        link = { sid: new_node.id, tid: descendant2_node.id }
        @nodes << descendant2_node
        @links << link
        @nodes_objects << descendant2
        # looking for other topics/domains associated with the reference
        if descendant2.type == "KnowledgeItem"
          # additional domain than the one that led to this reference
          if descendant2.ascendants.count > 1
            new_nodes_objects_alt = descendant2.ascendants.present? ? descendant2.ascendants - @nodes_objects : []
            # new node (ie not already in the map)
            descendant2.ascendants.each do |ascendant_topic|
              # add node & add link
              color_key = :secondary
              p " ascendant_topic.id : #{ascendant_topic.id}"
              ascendant_topic_node = @nodes.find{|node| node.object_id == ascendant_topic.id}
              if ascendant_topic_node.present?
                # ascendant_topic_node = @nodes.find{|node| node.object_id == ascendant_topic.id}
              else
                ascendant_topic_node = build_node(ascendant_topic, options: {color_key: color_key})
                @nodes << ascendant_topic_node
                @nodes_objects << ascendant_topic
              end
              link = { sid: ascendant_topic_node.id, tid: descendant2_node.id }
              @links << link
            end
          end
        end
      end
    end

    if node_object.type == "Domain"
      new_nodes_objects = node_object.users.uniq - [@node_object]
      create_linked_users_nodes(new_nodes_objects, new_node)
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
        knowledge_item: '#42C4EF',
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
