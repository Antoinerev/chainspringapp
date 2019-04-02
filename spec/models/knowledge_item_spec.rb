require 'rails_helper'

RSpec.describe KnowledgeItem, type: :model do
  describe "creation" do
    before do
      @user = FactoryBot.create(:user)
      @reference = FactoryBot.create(:reference)
      @reference.domains << FactoryBot.create(:topic)

    end

    it "can be created" do
      expect(@reference).to be_valid
    end
    pending "cannot be created without a domain"
    # it "cannot be created without a domain_id" do
    #   @reference.domains = []
    #   expect(@reference).to_not be_valid
    # end
    it "cannot be created without a user_id" do
      @reference.user_id = nil
      expect(@reference).to_not be_valid
    end
  end
end
