class Node
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  # include Rails.application.routes.url_helpers

  attr_accessor :name, :_color, :object_id, :object_type, :link, :kind, :time_needed, :topics, :_cssClass #, :svgSym
  attr_reader :id

  validates_presence_of :name

  @@id = 0

  def attributes
    {
      id: nil,
      name: nil,
      _color: nil,
      object_id: nil,
      object_type: nil,
      link: nil,
      kind: nil,
      time_needed: nil,
      topics: nil,
      # svgSym: nil
      _cssClass: nil
    }
  end

  def initialize(params)
    if params[:link].present?
      @name = params[:name]
    else
      @name = params[:name]
    end
    @_color = params[:_color] || ""
    @object_id = params[:id]
    @object_type = params[:type]
    @link = params[:link] || ""
    @kind = params[:kind] || ""
    @time_needed = params[:time_needed] || ""
    @topics = params[:topics] || ""
    @_cssClass = params[:link].present? ? 'ref-link' : ''

    if self.valid?
      @id = new_id
      return self
    else
      return self.errors.messages
    end
  end
  def type
    self.class.to_s
  end

  private

  # def svgSym
  #   if @link.present?
  #     return ActionController::Base.helpers.image_url("ext_link.png")
  #   else
  #     return ""
  #   end
  # end

  def new_id
    @@id+=1
  end

end
