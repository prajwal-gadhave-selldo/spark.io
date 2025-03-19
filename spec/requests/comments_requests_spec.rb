require "rails_helper"

RSpec.describe "CommentsController", type: :request do
  let(:user) { FactoryBot.create(:user, email: "admin@gmail.com") }
  let(:blog) { FactoryBot.create(:blog) }

  describe "#create" do
    let(:valid_params) do
      { comment: { content: "This is a test comment." } }
    end

    context "when user is logged in" do
      it "adds a comment successfully" do
        post blog_comments_path(blog), params: valid_params, headers: AuthHelper.authenticate(user)

        expect(response).to redirect_to(blog_path(blog))
        expect(flash[:notice]).to eq("Comment was successfully added.")
        expect(blog.comments.count).to eq(1)
      end

      it "fails to add a comment when content is empty" do
        post blog_comments_path(blog), params: { comment: { content: "" } }, headers: AuthHelper.authenticate(user)

        expect(response).to redirect_to(blog_path(blog))
        expect(flash[:notice]).to eq("Error adding comment.")
        expect(blog.comments.count).to eq(0)
      end
    end

    context "when blog does not exist" do
      it "returns blog not found error" do
        post blog_comments_path(id: -1, blog_id: -1), params: valid_params, headers: AuthHelper.authenticate(user)

        expect(response).to redirect_to(blogs_path)
        expect(flash[:alert]).to eq("Blog not found.")
      end
    end
  end
end
