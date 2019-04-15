require 'rails_helper'

RSpec.describe 'References requests' do
  describe 'POST new_ki' do
    before do
      @topic = FactoryBot.create(:domain)
      @topic2 = FactoryBot.create(:topic2)
      @user = FactoryBot.create(:user)
      login_as(@user, :scope => :user)
    end
    it 'creates a new reference with an existing topic without duplicating it' do
      topics_nb = Domain.count
      params = {newInfo: {title: "new test reference", user_id: @user.id,  domain_name: @topic.name}}
      post(api_v1_map_addki_path(params))

      expect(KnowledgeItem.last.title.capitalize).to eql(params[:newInfo][:title].capitalize)
      expect(Domain.count).to eql(topics_nb)
    end

    it 'creates a new reference with a new topic' do
      new_topic_name = "new topic not in db"
      topics_nb = Domain.count
      params = {newInfo: {title: "new test reference with new topic", user_id: @user.id,  domain_name: new_topic_name}}
      post(api_v1_map_addki_path(params))
      new_ki = KnowledgeItem.last
      expect(new_ki.title.capitalize).to eql(params[:newInfo][:title].capitalize)
      expect(new_ki.domains.last.name.capitalize).to eql(new_topic_name.capitalize)
      expect(Domain.count).to eql(topics_nb + 1)
    end

    it 'creates a new reference with three topics, comma separated (2 existing 1 new)' do
      existing_topics = "#{@topic.name}, #{@topic2.name}"
      new_topic_name = "another new topic not in db"
      topics_nb = Domain.count
      topics = "#{existing_topics}, #{new_topic_name}"
      params = {newInfo: {title: "new test reference with several topics", user_id: @user.id,  domain_name: topics}}
      post(api_v1_map_addki_path(params))
      new_ki = KnowledgeItem.last
      expect(new_ki.title.capitalize).to eql(params[:newInfo][:title].capitalize)
      expect(new_ki.domains.last.name.capitalize).to eql(new_topic_name.capitalize)
      expect(new_ki.domains.count).to eq(3)
      expect(Domain.count).to eql(topics_nb + 1)
    end

    # it 'returns the topic name' do
    #   params = { keyword: @topic.name }
    #   get(api_v1_map_search_path(params))
    #   response_json = JSON.parse(response.body)
    #   expect(response_json['map']['name'].capitalize).to eql(@topic.name.capitalize)
    # end
  end
end
