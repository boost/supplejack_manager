# The majority of The Supplejack Manager code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3. Some components are 
# third party components that are licensed under the MIT license or otherwise publicly available. 
# See https://github.com/DigitalNZ/supplejack_manager for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. 
# http://digitalnz.org/supplejack

require 'spec_helper'

describe ParsersController do

  let(:parser) { mock(:parser, id: "1234", to_param: "1234").as_null_object }
  let(:user) { mock_model(User, id: "1234").as_null_object }

  before(:each) do
    controller.stub(:authenticate_user!) { true }
    controller.stub(:current_user) { user }
  end

  describe "GET 'index'" do
    it "finds all the parser configurations" do
      Parser.should_receive(:all) { [parser] }
      get :index
      assigns(:parsers).should eq [parser]
    end
  end

  describe "GET show" do
    it "finds an existing parser " do
      Parser.should_receive(:find).with("1234") { parser }
      get :show, id: "1234"
      assigns(:parser).should eq parser
    end
  end

  describe "GET 'new'" do
    it "initializes a new parser" do
      Parser.should_receive(:new) { parser }
      get :new
      assigns(:parser).should eq parser
    end
  end

  describe "GET 'edit'" do
    let(:job) { mock_model(HarvestJob).as_null_object }
    let(:user) { mock_model(User, id: "333").as_null_object }

    before(:each) do
      Parser.stub(:find) { parser }
    end

    it "finds an existing parser " do
      Parser.should_receive(:find).with("1234") { parser }
      get :edit, id: "1234"
      assigns(:parser).should eq parser
    end

    it "initializes a harvest_job" do
      HarvestJob.should_receive(:from_parser).with(parser, user) { job }
      get :edit, id: "1234"
      assigns(:harvest_job).should eq job
    end
  end

  describe "GET 'create'" do
    before do 
      Parser.stub(:new) { parser }
      parser.stub(:save) { true }
    end

    it "initializes a new parser" do
      Parser.should_receive(:new).with({"name" => "Tepapa"}) { parser }
      post :create, parser: {name: "Tepapa"}
    end

    it "saves the parser" do
      parser.should_receive(:save)
      post :create, parser: {name: "Tepapa"}
    end

    context "valid parser" do
      before { parser.stub(:save) { true }}

      it "redirects to edit page" do
        post :create, parser: {name: "Tepapa"}
        response.should redirect_to edit_parser_path("1234")
      end
    end

    context "invalid parser" do
      before { parser.stub(:save) { false }}

      it "renders the edit action" do
        post :create, parser: {name: "Tepapa"}
        response.should render_template(:new)
      end
    end
  end

  describe "GET 'update'" do
    before do 
      Parser.stub(:find) { parser }
      parser.stub(:update_attributes) { true }
    end

    it "finds an existing parser " do
      Parser.should_receive(:find).with("1234") { parser }
      put :update, id: "1234"
      assigns(:parser).should eq parser
    end

    it "updates the parser attributes" do
      parser.should_receive("attributes=").with({"name" => "Tepapa"})
      put :update, id: "1234", parser: {name: "Tepapa"}
    end

    it "saves the parser" do
      parser.should_receive(:save)
      put :update, id: "1234", parser: {name: "Tepapa"}
    end

    context "valid parser" do
      before { parser.stub(:save) { true }}

      it "redirects to edit page" do
        put :update, id: "1234"
        response.should redirect_to edit_parser_path("1234")
      end
    end

    context "invalid parser" do
      before { parser.stub(:save) { false }}

      it "renders the edit action" do
        put :update, id: "1234"
        response.should render_template(:edit)
      end
    end
  end

  describe "GET 'destroy'" do
    before do 
      Parser.stub(:find) { parser }
      parser.stub(:destroy) { true }
    end

    context "job not running for parser" do

      before { parser.stub(:running_jobs?) { false } }

      it "finds an existing parser " do
        Parser.should_receive(:find).with("1234") { parser }
        delete :destroy, id: "1234"
        assigns(:parser).should eq parser
      end

      it "destroys the parser config" do
        parser.should_receive(:destroy)
        delete :destroy, id: "1234"
      end
    end

    it "does not destroy if there are currently running jobs" do
      parser.stub(:running_jobs) { true }
      parser.should_not_receive(:destroy)
      delete :destroy, id: "1234"
    end
  end

  describe "GET 'allow_flush'" do
    before do 
      Parser.stub(:find) { parser }
      parser.stub(:allow_full_and_flush) { true }
      parser.stub(:save) { true }
    end

    it 'sets the allow_full_and_flush to true' do
      get :allow_flush, id: parser, allow: true
      expect(assigns(:parser).allow_full_and_flush).to be_true
    end
  end

end
