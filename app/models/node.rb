class Node
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :name, :_color
  attr_reader :id

  validates_presence_of :name

  @@id = 0

  def attributes
    {
      id: nil,
      name: nil,
      _color: nil
    }
  end

  def initialize(params)
    @name = params[:name]
    @_color = params[:_color] || ""
    if self.valid?
      @id = new_id
      return self
    else
      return node.errors.messages
    end

  end

  private

  def new_id
    @@id+=1
  end

end
