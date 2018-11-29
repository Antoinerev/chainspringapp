class KnowledgeMap
  attr_accessor :user, :nodes, :links

  def initialize(node_object)
    @node_object = node_object
  end
  def build_v1
    node_colors = {
      user: '#26a424',
      linked_user: '#B3D5B2',
      domain: '#fc770a',
      knowledge_item: '#42c4ef',
      secondary: '#B3D5B2'
    }
    link_colors =  {
      primary: '#87db1c',
      secondary: '#D1D6A1'
    }
    @nodes_objects = []
    @nodes = []
    @links = []
    @id = 1

    if @node_object
      node = Node.new(id: @node_object.id, type: @node_object.type, name: @node_object.name, _color: node_colors[node_key(@node_object)])
      @nodes << node
      @nodes_objects << @node_object

      new_nodes_objects = @node_object.ascendants.present? ? @node_object.ascendants - @nodes_objects : []
      if new_nodes_objects.present?
        new_nodes_objects.each do |ascendant|
          ascendant_node = Node.new(id: ascendant.id, type: ascendant.type, name: ascendant.name, _color: node_colors[node_key(ascendant)])
          link = { sid: node.id, tid: ascendant_node.id }
          @nodes << ascendant_node
          @links << link
        end
        @nodes_objects += new_nodes_objects
      end

      new_nodes_objects = get_linked_users(@node_object).present? ? get_linked_users(@node_object) - @nodes_objects : []
      if new_nodes_objects.present?
        puts "linked_users : #{new_nodes_objects}"
        puts "@nodes_objects : #{@nodes_objects}"
        new_nodes_objects.each do |linked_user|
          linked_user_node = Node.new(id: linked_user.id, type: linked_user.type, name: linked_user.name, _color: node_colors[:linked_user])
          link = { sid: node.id, tid: linked_user_node.id, _color: link_colors[:secondary] }
          @nodes << linked_user_node
          @links << link
        end
        @nodes_objects += new_nodes_objects
      end

      new_nodes_objects = @node_object.descendants.present? ? @node_object.descendants - @nodes_objects : []
      if new_nodes_objects.present?
        new_nodes_objects.each do |descendant|
          descendant_node = Node.new(id: descendant.id, type: descendant.type, name: descendant.name, _color: node_colors[node_key(descendant)])
          link = { sid: node.id, tid: descendant_node.id }
          @nodes << descendant_node
          @links << link

          new_nodes_objects_desc = descendant.descendants.present? ? descendant.descendants - @nodes_objects : []
          if new_nodes_objects_desc.present?
            new_nodes_objects_desc.each do |descendant2|
              if descendant2.type == 'KnowledgeItem' && descendant2.user == @nodes_objects.first
                node_color = node_colors[node_key(descendant2)]
                link_color = link_colors[:primary]
              else
                node_color = node_colors[:secondary]
                link_color = link_colors[:secondary]
              end
              descendant2_node = Node.new(id: descendant2.id, type: descendant2.type, name: descendant2.name, _color: node_color)
              link = { sid: descendant_node.id, tid: descendant2_node.id, _color: link_color }
              @nodes << descendant2_node
              @links << link
            end
            @nodes_objects += new_nodes_objects_desc
          end
        end
        @nodes_objects += new_nodes_objects
      end

      return {name: @node_object.name, nodes: @nodes, links: @links}

    else
      return {name: "", nodes: @nodes, links: @links, message: "no record found"}
    end
  end

  private

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

end
