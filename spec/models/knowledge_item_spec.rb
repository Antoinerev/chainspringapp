require 'rails_helper'

RSpec.describe KnowledgeItem, type: :model do
  describe "creation" do
    before do
      @user = FactoryBot.create(:user)
      @topic = FactoryBot.create(:topic)
      @reference = FactoryBot.create(:reference)
    end

    it "can be created" do
      expect(@reference).to be_valid
    end
    it "cannot be created without a domain_id" do
      @reference.domain_id = nil
      expect(@reference).to_not be_valid
    end
    it "cannot be created without a user_id" do
      @reference.user_id = nil
      expect(@reference).to_not be_valid
    end
  end
end
