require 'rails_helper'

RSpec.describe 'Maps requests' do
  describe 'GET /build_map' do
    it 'returns a status message' do
      get(api_v1_map_build_path)
      expect(response.status).to eql(200)
    end
  end
  describe 'GET /search' do
    before do
      @topic = FactoryBot.create(:domain)
    end
    it 'returns a status message' do
      params = { keyword: @topic.name }
      get(api_v1_map_search_path(params))
      expect(response.status).to eql(200)
    end

    it 'returns the topic name' do
      params = { keyword: @topic.name }
      get(api_v1_map_search_path(params))
      response_json = JSON.parse(response.body)
      expect(response_json['map']['name'].capitalize).to eql(@topic.name.capitalize)
    end
  end
end
