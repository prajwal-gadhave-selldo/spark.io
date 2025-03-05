require 'rails_helper'

RSpec.describe "UsersController", type: :request do
  describe 'POST /signup' do
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
      it 'create a new user and redirect to login' do
        post "/signup", params: params
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end
