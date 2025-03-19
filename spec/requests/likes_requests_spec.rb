require "rails_helper"

RSpec.describe "Likes", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:blog) { FactoryBot.create(:blog, user: user) }

  describe "#create" do
    context "when user is logged in" do
      it "likes the blog successfully" do
        post blog_likes_path(blog), headers: AuthHelper.authenticate(user)

        expect(response).to redirect_to(blog_path(blog))
        expect(flash[:notice]).to eq("Blog liked!")
        expect(blog.likes.count).to eq(1)
      end

      it "fails to like the blog if already liked" do
        FactoryBot.create(:like, user: user, blog: blog) # First like
        
        post blog_likes_path(blog), headers: AuthHelper.authenticate(user) # Second like attempt
  
        expect(response).to redirect_to(blog_path(blog))
        expect(blog.likes.count).to eq(1) # Should still be only 1 like
      end
    end

    context "when user is not logged in" do
      it "redirects to login page" do
        post blog_likes_path(blog)

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Please login first.")
      end
    end

    context "when blog does not exist" do
      it "redirects to root path with an error" do
        post blog_likes_path(id: "-1", blog_id: "-1"), headers: AuthHelper.authenticate(user)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Blog not found.")
      end
    end
  end

  describe "#destroy" do
    let!(:like) { FactoryBot.create(:like, user: user, blog: blog) }

    context "when user is logged in" do
      it "unlikes the blog successfully" do
        delete like_path(like), headers: AuthHelper.authenticate(user)

        expect(response).to redirect_to(blog_path(blog))
        expect(flash[:notice]).to eq("Blog unliked!")
        expect(blog.likes.count).to eq(0)
      end
    end

    context "when user is not logged in" do
      it "redirects to login page" do
        delete like_path(like)

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Please login first.")
      end
    end

    context "when user tries to unlike a blog they haven't liked" do
      it "raises ActiveRecord::RecordNotFound" do
        another_user = FactoryBot.create(:user, email: "second@admin.com")

        expect {
          delete like_path(like), headers: AuthHelper.authenticate(another_user)
        }.to change(Like, :count).by(0)
      end
    end
  end
end
