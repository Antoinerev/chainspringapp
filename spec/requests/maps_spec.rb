require 'rails_helper'

RSpec.describe 'Maps requests' do
  describe 'GET /build_map' do
    it 'returns a status message' do
      get(api_v1_map_build_path)
      # response_json = JSON.parse(response.body)
      # expect(response_json['status']).to eql('ok')
      expect(response.status).to eql(200)
    end
  end
end
