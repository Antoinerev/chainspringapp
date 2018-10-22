class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @user_map = KnowledgeMap.new(@user).build_v1
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
end
