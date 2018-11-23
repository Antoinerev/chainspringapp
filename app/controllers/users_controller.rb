class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  def index
    @users = User.all
  end

  def show
    if params[:id]
      @user = User.find(params[:id])
    elsif current_user
      @user = current_user
    else
      @user = User.find(3)
    end
    @user_map = KnowledgeMap.new(@user).build_v1
    @user_map[:id] = current_user ? current_user.id : nil
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
