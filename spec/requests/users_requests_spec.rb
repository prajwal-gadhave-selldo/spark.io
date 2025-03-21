require 'rails_helper'

RSpec.describe "UsersController", type: :request do
  describe '#signup' do
    let(:params) do
      {
        user: {
          name: 'Rushi',
          email: 'rushi@gmail.com',
          password: 'password',
          password_confirmation: 'password'
        }
      }
    end

    context 'when valid parameters are provided' do
      it 'create a new user and redirect to dashboard' do
        post signup_path, params: params
        expect(response).to redirect_to(dashboard_path)
      end
      it "shows the signup form" do
        get "/signup"
        expect(response).to render_template(:new)
      end
    end

    context 'when invalid parameters are provided' do
      it 'for does not create a new user and render new template' do
        post "/signup", params: { user: { name: 'Rushi' } }
        expect(response).to render_template(:new)
      end

      it 'does not create a new user and render new template' do
        post "/signup", params: { user: { name: 'Rushi', email: 'rushi@gmail.com', password: 'password', password_confirmation: 'password1' } }
        expect(response).to render_template(:new)
      end
    end

    context 'when user already exists' do
      before { User.create!(params[:user]) }

      it 'does not create a new user and render new template' do
        post "/signup", params: params
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#login' do
    let(:user) { FactoryBot.create(:user) }
    let(:valid_params) { { email: user.email, password: 'password' } }
    let(:invalid_params) { { user: { email: user.email, password: 'wrongpassword' } } }

    context 'when valid credentials are provided' do
      it 'logs in the user and redirects to dashboard' do
        post login_path, params: valid_params
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context 'when invalid credentials are provided' do
      it 'does not log in the user and renders login template' do
        post login_path, params: invalid_params
        expect(response).to render_template(:new)
      end
    end

    context 'when user does not exist' do
      it 'does not log in the user and renders login template' do
        post login_path, params: { session: { email: 'unknown@gmail.com', password: 'password' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#logout' do
    let(:user) { FactoryBot.create(:user) }

    before do
      post login_path, params: { email: user.email, password: 'password' }
    end

    it 'logs out the user and redirects to login page' do
      delete logout_path
      expect(response).to redirect_to(login_path)
      expect(cookies[:jwt]).to be_empty
    end
  end

  describe "#not_found" do
    it "renders 404 page" do
      get "/12345"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#dashboard" do
    let(:user) { FactoryBot.create(:user) }

    before do
      post login_path, params: { email: user.email, password: 'password' }
    end

    it "renders dashboard page" do
      get dashboard_path
      expect(response).to render_template(:dashboard)
    end
  end
end
