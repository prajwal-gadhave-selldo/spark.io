require "rails_helper"

RSpec.describe "BlogsController", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user, email: "second@admin.com") }
  let!(:blog) { FactoryBot.create(:blog, user: user) }

  describe "#create" do
    let(:params) do
      {
        blog: {
          title: "My first blog",
          content: "This is my first blog post"
        }
      }
    end

    context "when valid parameters are provided" do
      it "creates a new blog and redirect to show blog page" do
        post blogs_path, params: params, headers: AuthHelper.authenticate(user)
        expect(response).to have_http_status(:found)
      end
    end

    context "when invalid parameters are provided" do
      it "does not create a new blog and renders new template" do
        post blogs_path, params: { blog: { title: "", content: "" } }, headers: AuthHelper.authenticate(user)
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#index" do
    context "when user is logged in" do
      it "returns a list of blogs" do
        get blogs_path, headers: AuthHelper.authenticate(user)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#show" do
    context "when the blog exists" do
      it "returns the blog details" do
        get blog_path(blog)
        expect(response).to have_http_status(:found)
      end
    end

    context "when the blog does not exist" do
      it "redirects to the root path with an error message" do
        get blog_path(id: "-1")
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Blog not found.")
      end
    end
  end
  
  describe "#update" do
    let(:valid_params) do
      {
        blog: {
          title: "Updated Title",
          content: "Updated Content"
        }
      }
    end

    let(:invalid_params) do
      {
        blog: {
          title: "",
          content: ""
        }
      }
    end

    context "when user is the owner" do
      it "updates the blog and redirects to the blog page" do
        patch blog_path(blog), params: valid_params, headers: AuthHelper.authenticate(user)
        expect(response).to redirect_to(blog)
        expect(blog.reload.title).to eq("Updated Title")
      end

      it "fails to update with invalid data and renders edit template" do
        patch blog_path(blog), params: invalid_params, headers: AuthHelper.authenticate(user)
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when user is not the owner" do
      it "does not update the blog and redirects to blogs path" do
        patch blog_path(blog), params: valid_params, headers: AuthHelper.authenticate(other_user)
        expect(response).to redirect_to(blogs_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  describe "#destroy" do
    context "when user is the owner" do
      it "deletes the blog and redirects to blogs path" do
        delete blog_path(blog), headers: AuthHelper.authenticate(user)
        expect(response).to redirect_to(blogs_path)
        expect(Blog.exists?(blog.id)).to be_falsey
      end
    end

    context "when user is not the owner" do
      it "does not delete the blog and redirects to blogs path" do
        delete blog_path(blog), headers: AuthHelper.authenticate(other_user)
        expect(response).to redirect_to(blogs_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        expect(Blog.exists?(blog.id)).to be_truthy
      end
    end
  end

  describe "#new" do
    context "when user is logged in" do
      it "renders the new blog form" do
        get new_blog_path, headers: AuthHelper.authenticate(user)
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:new)
      end
    end

    context "when user is not logged in" do
      it "redirects to the login page" do
        get new_blog_path
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Please login first.")
      end
    end
  end
end
