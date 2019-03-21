class Api::V1::MapsController < Api::V1::BaseController
  # before_action :set_node, only: :build_map
  skip_before_action :verify_authenticity_token

  def build_map
    set_node unless @node
    if params[:build_version]
      map = KnowledgeMap.new(@node).send("build_#{params[:build_version]}")
    else
      map = KnowledgeMap.new(@node).build_v1
    end
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

  def create_ki
    new_ki = KnowledgeItem.new(ki_params)

    if new_ki.save
      redirect_to user_path(@user), notice: "new KI saved"
    else
      redirect_to user_path(@user), alert: "new KI could not be saved"
    end
  end
  def update_ki
    edited_ki = KnowledgeItem.find(params[:newInfo][:object_id])

    if edited_ki.update(ki_params)
      redirect_to user_path(@user), notice: "new KI successfully edited"
    else
      redirect_to user_path(@user), alert: "KI modifications could not be saved"
    end
  end


  private

  def get_params
    @localization = params[:localization]
  end
  def ki_params
    safe_params = params.require(:newInfo).permit(:user_id, :title, :kind, :link, :time_needed)
    if params[:newInfo][:domain_name].present?
      safe_params[:domain_id] = get_domain_id(params[:newInfo][:domain_name])
    end
    return safe_params
  end
  def get_domain_id(domain_name)
    if domain_name
      puts "domain_name : #{domain_name}"
      domain = Domain.new(name: domain_name)
      domain = compact_similar(domain)
      return domain.id
    else
      return nil
    end
  end
  def compact_similar(domain)
    similar_domains = Domain.where(name: domain.name)
    if similar_domains.size > 1

      total_knowledge_items = similar_domains.map(&:knowledge_items).flatten
      domain = similar_domains.first
      similar_domains -= [domain]
      similar_domains.each do |redondant_domain|
        redondant_domain.knowledge_items.each{|ki| ki.update(domain_id: domain.id)}

      end
      if domain.knowledge_items.count == total_knowledge_items.count
        similar_domains.each{|domain| domain.delete}
      end
    end
    domain.save
    return domain
  end

  def set_node
    node_id = params[:node_id].to_i
     if params[:node_class]
      node_class = Object.const_get params[:node_class].camelize
      @node =  node_class.find(node_id)
    else
      nil
    end
  end

end
