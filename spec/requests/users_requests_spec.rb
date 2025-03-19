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
        binding.pry
        expect(response).to redirect_to(dashboard_path)
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
  
end
