require 'rails_helper'

RSpec.describe Domain, type: :model do
  describe "creation" do
    before do
      @topic = FactoryBot.create(:topic)
    end

    it "can be created" do
      expect(@topic).to be_valid
    end
  end
end
