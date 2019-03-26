require 'rails_helper'

RSpec.describe 'References requests' do
  describe 'POST new_ki' do
    before do
      @topic = FactoryBot.create(:domain)
      @user = FactoryBot.create(:user)
      login_as(@user, :scope => :user)
    end
    it 'creates a new reference with an existing topic' do
      params = {newInfo: {title: "new test reference", user_id: @user.id,  domain_name: @topic.name}}
      post(api_v1_map_addki_path(params))

      expect(KnowledgeItem.last.title.capitalize).to eql(params[:newInfo][:title].capitalize)
    end

    # it 'returns the topic name' do
    #   params = { keyword: @topic.name }
    #   get(api_v1_map_search_path(params))
    #   response_json = JSON.parse(response.body)
    #   expect(response_json['map']['name'].capitalize).to eql(@topic.name.capitalize)
    # end
  end
end
