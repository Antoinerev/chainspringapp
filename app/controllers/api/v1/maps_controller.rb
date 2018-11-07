class Api::V1::MapsController < Api::V1::BaseController
  before_action :set_node, only: :build_map

  def build_map
    map = KnowledgeMap.new(@node).build_v1
    response = {map: map, alternative_nodes: @nodes_array}
    render json: response
  end

  def search
    keyword = params[:keyword].capitalize
    @nodes_array = []
    begin
      puts keyword
      nodes = Domain.where('name like ?', "%#{keyword}%").limit(6)
      @nodes_array = nodes.to_a
      keyword = keyword[0...keyword.length - 1]
      break if keyword.length <= 1
    end while @nodes_array.length == 0
    @node = @nodes_array.shift
    build_map
  end


  private

  def get_params
    @localization = params[:localization]
  end

  def set_node
    node_id = params[:node_id].to_i
    node_class = Object.const_get params[:node_class].camelize

    @node =  node_class.find(node_id)
  end

end
