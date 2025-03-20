require 'rails_helper'

RSpec.describe BlogsService, type: :service do
  let(:user) { FactoryBot.create(:user) }
  let(:another_user) { FactoryBot.create(:user) }
  let!(:blog) { FactoryBot.create(:blog, user: user) }
  let(:valid_attributes) { { title: "New Blog", content: "This is a test blog" } }
  let(:invalid_attributes) { { title: "", content: "" } }

  describe ".index" do
    it "returns blogs of the given user in descending order" do
      blogs = BlogsService.index(user)
      expect(blogs).to eq(user.blogs.order(created_at: :desc))
    end
  end

  describe ".show" do
    it "returns blog details and comments if the blog exists" do
      response = BlogsService.show(blog.id)
      expect(response[:success]).to be true
      expect(response[:blog]).to eq(blog)
      expect(response[:comments]).to eq(blog.comments.order(created_at: :desc))
    end

    it "returns an error if the blog does not exist" do
      response = BlogsService.show(-1)
      expect(response[:success]).to be false
      expect(response[:error]).to eq("Blog not found.")
    end
  end

  describe ".create" do
    it "creates a blog with valid attributes" do
      response = BlogsService.create(user, valid_attributes)
      expect(response[:success]).to be true
      expect(response[:blog]).to be_persisted
    end

    it "fails to create a blog with invalid attributes" do
      response = BlogsService.create(user, invalid_attributes)
      expect(response[:success]).to be false
      expect(response[:blog]).not_to be_persisted
    end
  end

  describe "#update" do
    it "updates the blog successfully" do
      response = BlogsService.update(blog, { title: "Updated Title" })
      expect(response[:success]).to be true
      expect(blog.reload.title).to eq("Updated Title")
    end

    it "fails to update the blog with invalid attributes" do
      response = BlogsService.update(blog, { title: "" })
      expect(response[:success]).to be false
      expect(blog.reload.title).not_to eq("")
    end
  end

  describe "#destroy" do
    it "destroys the blog successfully" do
      response = BlogsService.destroy(blog)
      expect(response[:success]).to be true
      expect(Blog.exists?(blog.id)).to be false
    end
  end

  describe "#owner?" do
    it "returns true if the user is the owner of the blog" do
      expect(BlogsService.owner?(blog, user)).to be true
    end

    it "returns false if the user is not the owner of the blog" do
      expect(BlogsService.owner?(blog, another_user)).to be false
    end
  end

  describe ".fetch" do
    it "returns the blog if it exists" do
      response = BlogsService.fetch(blog.id)
      expect(response[:success]).to be true
      expect(response[:blog]).to eq(blog)
    end

    it "returns an error if the blog does not exist" do
      response = BlogsService.fetch(-1)
      expect(response[:success]).to be false
      expect(response[:error]).to eq("Blog not found.")
    end
  end
end
