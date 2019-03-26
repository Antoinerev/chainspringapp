require 'rails_helper'

RSpec.describe User, type: :model do
  describe "creation" do
    before do
      @user = FactoryBot.create(:user)
    end

    it "can be created" do
      expect(@user).to be_valid
    end
  end
end
