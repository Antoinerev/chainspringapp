class UsersController < ApplicationController
  # before_action :authenticate_user!, except: [:index, :show]
  CURRENT_VERSION = "v4"
  def index
    @users = User.all
  end

  def show
    if params[:id]
      @user = User.find(params[:id])
    elsif current_user
      @user = current_user
    else
      @user = User.first
    end
    @map_params = KnowledgeMap.new(@user).send("build_#{CURRENT_VERSION}")
    @map_params[:user_id] = current_user ? current_user.id : nil
  end

  def new
  end

  def create
  end

  def edit
    # @user = User.find(params[:id])
    # @markdown_reader = MarkdownReader.new()
  end

  def update
    # @user = User.find(params[:id])
    # @markdown_reader = MarkdownReader.new(params[:input_file])
  end

  def destroy
  end

  private

  def set_user

  end
end
