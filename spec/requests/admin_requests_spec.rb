require "rails_helper"

RSpec.describe AdminController, type: :request do
  let(:admin) { FactoryBot.create(:user, role: "admin", email: "admin@gmail.com") }
  let(:user) { FactoryBot.create(:user, email: "new@gmail.com") }
  let(:user_for_blog) { FactoryBot.create(:user, email: "new1@gmail.com") }
  let(:blog) { FactoryBot.create(:blog) }

  before do
    allow(AdminService).to receive(:is_admin?).and_return(true)
  end

  describe "#dashboard" do
    it "loads the dashboard successfully" do
      dashboard_data = {
        total_users: 10,
        total_blogs: 5,
        total_comments: 20,
        total_likes: 50,
        new_users_count: 2,
        user_growth_data: [ 1, 2, 3 ],
        content_data: { blogs: 5, comments: 20 },
        latest_users: [],
        latest_blogs: []
      }

      allow(AdminService).to receive(:dashboard_data).and_return(dashboard_data)

      get admin_dashboard_path, headers: AuthHelper.authenticate(admin)
      expect(response).to have_http_status(:ok)
      expect(assigns(:total_users)).to eq(10)
      expect(assigns(:total_blogs)).to eq(5)
    end
  end

  describe "#activity" do
    it "loads activity data successfully" do
      activity_data = {
        start_date: 30.days.ago.to_date,
        daily_data: [],
        active_users: [],
        popular_blogs: []
      }

      allow(AdminService).to receive(:activity_data).with("30_days").and_return(activity_data)

      get admin_activity_path, params: { range: "30_days" }, headers: AuthHelper.authenticate(admin)
      expect(response).to have_http_status(:success)
      expect(assigns(:start_date)).to eq(30.days.ago.to_date)
    end
  end

  describe "#users" do
    let!(:user1) { FactoryBot.create(:user, email: "user@gmail.com") }
    let!(:user2) { FactoryBot.create(:user, email: "user2@gmail.com") }

    it "downloads CSV successfully" do
      allow(AdminService).to receive(:filter_users).and_return([ user1, user2 ])
      allow(AdminService).to receive(:generate_users_csv).and_return("id,name,email\n1,Test, test@example.com")

      get admin_users_path, params: { format: :csv }, headers: AuthHelper.authenticate(admin)

      expect(response).to have_http_status(:success)
      expect(response.headers["Content-Type"]).to include("text/csv")
    end
  end

  describe "#update_user" do
    it "updates user details successfully" do
      updated_attributes = { name: "Updated Name", email: "updated@example.com" }

      allow(AdminService).to receive(:update_user).with(user, ActionController::Parameters.new(updated_attributes).permit!).and_return({ success: true })

      patch admin_user_path(user), params: { user: updated_attributes }, headers: AuthHelper.authenticate(admin)

      expect(response).to redirect_to(admin_user_path(user))
    end

    it "renders edit_user when update fails" do
      allow(AdminService).to receive(:update_user).and_return({ success: false, user: user })

      patch admin_user_path(user), params: { user: { name: "" } }, headers: AuthHelper.authenticate(admin)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "redirects when user is not found" do
      allow(User).to receive(:find_by).and_return(nil)

      patch admin_user_path(-1), params: { user: { name: "Test" } }, headers: AuthHelper.authenticate(admin)

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq("User not found.")
    end
  end

  describe "#user_activity" do
    it "retrieves user activity data" do
      activity_data = {
        blogs: [ blog ],
        comments: [],
        likes: []
      }

      allow(AdminService).to receive(:user_activity).with(user).and_return(activity_data)

      get admin_user_activity_path(user), headers: AuthHelper.authenticate(admin)

      expect(response).to have_http_status(:success)
      expect(assigns(:blogs)).to eq([ blog ])
    end
  end

  describe "#blogs" do
    let!(:blog1) { FactoryBot.create(:blog) }
    let!(:blog2) { FactoryBot.create(:blog, user: user_for_blog) }

    it "downloads blogs as CSV successfully" do
      allow(AdminService).to receive(:filter_blogs).and_return([ blog1, blog2 ])
      allow(AdminService).to receive(:generate_blogs_csv).and_return("id,title,content\n1,Title,Content")

      get admin_blogs_path, params: { format: :csv }, headers: AuthHelper.authenticate(admin)

      expect(response).to have_http_status(:success)
      expect(response.headers["Content-Type"]).to include("text/csv")
      expect(response.body).to include("id,title,content")
    end
  end

  describe "#create_blog" do
    it "creates a new blog successfully" do
      blog_params = { title: "New Blog", content: "This is a test blog" }

      allow(AdminService).to receive(:create_blog).with(ActionController::Parameters.new(blog_params).permit!, admin).and_return({ success: true, blog: blog })

      post admin_blogs_path, params: { blog: blog_params }, headers: AuthHelper.authenticate(admin)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(admin_blogs_path)
    end

    it "renders new when blog creation fails" do
      allow(AdminService).to receive(:create_blog).and_return({ success: false, blog: Blog.new })

      post admin_blogs_path, params: { blog: { title: "" } }, headers: AuthHelper.authenticate(admin)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    # it "renders new when blog initialization fails" do
    #   allow(Blog).to receive(:new).and_return(nil)

    #   get new_admin_blog_path, headers: AuthHelper.authenticate(admin)

    # end
  end

  describe "#update_blog" do
    it "updates blog details successfully" do
      updated_attributes = { title: "Updated Title", content: "Updated content" }

      allow(AdminService).to receive(:update_blog).with(blog, ActionController::Parameters.new(updated_attributes).permit!).and_return({ success: true })

      patch admin_blog_path(blog), params: { blog: updated_attributes }, headers: AuthHelper.authenticate(admin)

      expect(response).to redirect_to(admin_blog_path(blog))
    end

    it "renders edit when update fails" do
      allow(AdminService).to receive(:update_blog).and_return({ success: false, blog: blog })

      patch admin_blog_path(blog), params: { blog: { title: "" } }, headers: AuthHelper.authenticate(admin)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "redirects when blog is not found" do
      allow(Blog).to receive(:find_by).and_return(nil)

      patch admin_blog_path(-1), params: { blog: { title: "Updated Title" } }, headers: AuthHelper.authenticate(admin)

      expect(response).to redirect_to(admin_blogs_path)
      expect(flash[:alert]).to eq("Blog not found.")
    end
  end

  describe "#destroy_blog" do
    it "deletes a blog successfully" do
      allow(AdminService).to receive(:destroy_blog).with(blog).and_return({ success: true })

      delete admin_blog_path(blog), headers: AuthHelper.authenticate(admin)

      expect(response).to redirect_to(admin_blogs_path)
    end
  end

  describe "Admin authorization" do
    it "redirects non-admin users" do
      allow(AdminService).to receive(:is_admin?).and_return(false)

      get admin_dashboard_path, headers: AuthHelper.authenticate(user)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to access this area.")
    end
  end
end
