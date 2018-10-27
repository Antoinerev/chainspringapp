class KnowledgeMap
  attr_accessor :user, :nodes, :links

  def initialize(node)
    @node = node
  end
  def build_v1
    node_colors = {
      user: 'red',
      domain: 'purple',
      knowledge_item: 'blue'
    }

    @nodes = []
    @links = []
    @id = 1

    node = Node.new(id: @node.id, type: @node.type, name: @node.name, _color: node_colors[node_key(@node)])
    @nodes << node
    if @node.ascendants
      @node.ascendants.each do |ascendant|
        ascendant_node = Node.new(id: ascendant.id, type: ascendant.type, name: ascendant.name, _color: node_colors[node_key(ascendant)])
        link = { sid: node.id, tid: ascendant_node.id }
        @nodes << ascendant_node
        @links << link
      end
    end
    if @node.descendants
      @node.descendants.each do |descendant|
        descendant_node = Node.new(id: descendant.id, type: descendant.type, name: descendant.name, _color: node_colors[node_key(descendant)])
        link = { sid: node.id, tid: descendant_node.id }
        @nodes << descendant_node
        @links << link
        if descendant.descendants
          descendant.descendants.each do |descendant2|
            descendant2_node = Node.new(id: descendant2.id, type: descendant2.type, name: descendant2.name, _color: node_colors[node_key(descendant2)])
            link = { sid: descendant_node.id, tid: descendant2_node.id }
            @nodes << descendant2_node
            @links << link
          end
        end
      end
    end
    return {name: @node.name, nodes: @nodes, links: @links}
  end

  private

  def node_key(node)
    node.type.underscore.to_sym
  end

end
