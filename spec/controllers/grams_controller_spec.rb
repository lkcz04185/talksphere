 require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  
  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should require users to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the new form" do
      user = FactoryGirl.create(:user)
      sign_in user
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do

    it "should require users to be logged in" do
      post :create, gram: {message: 'Hello!'}
      expect(response). to redirect_to new_user_session_path
    end

    it "should successfully create a new gram in the database" do
      user = FactoryGirl.create(:user)
      sign_in user
      post :create, gram: {
        message: 'Hello!',
        picture: fixture_file_upload('/picture.png', 'image/png')
      }

      expect(response).to redirect_to root_path
      gram = Gram.last
      expect(gram.message).to eq("Hello!")
      expect(gram.user).to eq(user)
    end

    it "should properly deal with the validation errors" do
      user = FactoryGirl.create(:user)
      sign_in user
      post :create, gram: {message: ''}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq 0
    end
  end

  describe "gram#show action" do
    it "should successfully show the page if the gram is found" do
      gram = FactoryGirl.create(:gram)
      get :show, id: gram.id
      expect(response).to have_http_status (:success)

    end

    it "should return a 404 error if the gram is not found" do
      get :show, id: 'TACOCAT'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "gram#edit ation" do
    it "should successfully show the edit page if the gram is found" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user
      get :edit, id: gram.id
      expect(response).to have_http_status (:success)
    end

    it "should return a 404 error message if the gram is not found" do
      user = FactoryGirl.create(:user)
      sign_in user
      get :edit, id: 'TACOCAT'
      expect(response).to have_http_status(:not_found)
    end

    it "shouldn't let an unautheticated user edit a gram" do
      gram = FactoryGirl.create(:gram)
      get :edit, id: gram.id
      expect(response).to redirect_to new_user_session_path
    end

    it "shouldn't let a user who doesn't created the gram to edit it" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      get :edit, id: gram.id
      expect(response).to have_http_status (:forbidden)
    end

  end

  describe "gram#update action" do
    it "should successfully update the gram" do
      gram = FactoryGirl.create(:gram, message: 'Initial Value')
      sign_in gram.user
      patch :update, id: gram.id, gram: {message: 'Changed'}
      expect(response).to redirect_to root_path
      gram.reload
      expect(gram.message).to eq 'Changed'
    end

    it "should have http 404 error if the gram cannot be found" do
      user = FactoryGirl.create(:user)
      sign_in user
      patch :update, id: 'YOLOSWAG', gram: {message: 'Changed'}
      expect(response).to have_http_status(:not_found)
    end

    it "should render the edit form with an http status unprocessable_entity" do
      gram = FactoryGirl.create(:gram, message: 'Initial Value')
      sign_in gram.user
      patch :update, id: gram.id, gram: {message: ''}
      expect(response).to have_http_status(:unprocessable_entity)
      gram.reload
      expect(gram.message).to eq 'Initial Value'
    end

    it "shouldn't let an unauthenticated user update a gram" do
      gram = FactoryGirl.create(:gram)
      patch :update, id: gram.id, gram: {message: 'Hello!'}
      expect(response).to redirect_to new_user_session_path
    end

    it "shouldn't let users who didn't create the gram update it" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      patch :update, id: gram.id, gram: {message: 'may not change me!'}
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "grams#destroy action" do
    it "should allow a user to destroy grams" do
      gram = FactoryGirl.create(:gram, message: 'Hello!')
      sign_in gram.user
      delete :destroy, id: gram.id
      expect(response).to redirect_to root_path
      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil
   end

    it "should return a 404 error message if a gram with the specified id not found" do
      user = FactoryGirl.create(:user)
      sign_in user
      delete :destroy, id: 'SPACEDUCK'
      expect(response). to have_http_status(:not_found)
    end

    it "shouldn't let an unauthenticated user to delete the gram" do
      gram = FactoryGirl.create(:gram)
      delete :destroy, id: gram.id
      expect(response).to redirect_to new_user_session_path
    end

    it "shouldn't allow users who didn't create the gram to destroy it" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      delete :destroy, id: gram.id
      expect(response).to have_http_status(:forbidden)
    end   
  end

end
