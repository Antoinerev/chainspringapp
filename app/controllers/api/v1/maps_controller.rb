class Api::V1::MapsController < Api::V1::BaseController
  # before_action :set_node, only: :build_map
  skip_before_action :verify_authenticity_token

  def build_map
    set_node unless @node
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

  def update
    @user = User.find(get_new_info[:userId].to_i)
    puts "@user : #{@user.id} / #{@user.name}"
    @domain = get_domain
    puts "@domain : #{@domain.id}"
    new_ki = KnowledgeItem.new(title: get_new_info[:title])
    new_ki.user = @user
    new_ki.domain = @domain
    puts "new_ki : #{new_ki}"

    if new_ki.save
      redirect_to user_path(@user), notice: "new KI saved"
    else
      redirect_to user_path(@user), alert: "new KI could not be saved"
    end
  end


  private

  def get_params
    @localization = params[:localization]
  end
  def get_new_info
    params.require(:newInfo).permit(:userId, :domain, :title, :kind, :link, :time_needed)
  end
  def get_domain
    if domain_name = get_new_info[:domain]
      puts "domain_name : #{domain_name}"
      domain = Domain.new(name: domain_name)
      domain = compact_similar(domain)
      return domain
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
