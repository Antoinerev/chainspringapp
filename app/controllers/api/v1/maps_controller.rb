class Api::V1::MapsController < Api::V1::BaseController
  before_action :set_node

  def build_map
    @map = KnowledgeMap.new(@node).build_v1
    render json: @map
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
