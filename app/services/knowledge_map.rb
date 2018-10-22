class KnowledgeMap
  attr_accessor :user, :nodes, :links

  def initialize(user)
    @user = user
  end
  def build_v1
    user_color = 'red'
    domain_color = 'purple'
    ki_color = 'blue'
    @nodes = []
    @links = []
    @id = 1

    user_node = Node.new(name: @user.name, _color: user_color)
    @nodes << user_node
    @user.unique_domains.each do |domain|
      domain_node = Node.new(name: domain.name, _color: domain_color)
      link = { sid: user_node.id, tid: domain_node.id }
      @nodes << domain_node
      @links << link
      domain.knowledge_items.each do |ki|
        ki_node = Node.new(name: ki.title, _color: ki_color)
        link = { sid: domain_node.id, tid: ki_node.id }
        @nodes << ki_node
        @links << link
      end
    end
    return {name: @user.name, nodes: @nodes, links: @links}
  end
end
