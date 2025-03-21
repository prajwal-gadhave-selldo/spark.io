require 'rails_helper'
require 'csv'

describe AdminService do
  let!(:users) { create_list(:user, 5) }
  let!(:blogs) { create_list(:blog, 3, user: users.first) }
  let!(:comments) { create_list(:comment, 10, blog: blogs.first, user: users.second) }
  let!(:likes) do
    users.each_with_index.map do |user, index|
      create(:like, blog: blogs[index % blogs.size], user: user) # Ensures unique user-blog pairs
    end
  end

  describe '.dashboard_data' do
    it 'returns correct dashboard data' do
      data = AdminService.dashboard_data
      expect(data[:total_users]).to eq(User.count)
      expect(data[:total_blogs]).to eq(Blog.count)
      expect(data[:total_comments]).to eq(Comment.count)
      expect(data[:total_likes]).to eq(Like.count)
      expect(data[:latest_users].size).to be <= 5
      expect(data[:latest_blogs].size).to be <= 5
    end
  end

  describe '.activity_data' do
    it 'returns correct activity data for 30 days' do
      data = AdminService.activity_data("30_days")
      expect(data[:daily_data]).not_to be_empty
      expect(data[:active_users]).not_to be_nil
      expect(data[:popular_blogs]).not_to be_nil
    end

    it 'returns correct activity data for 7 days' do
      data = AdminService.activity_data("7_days")
      expect(data[:daily_data]).not_to be_empty
      expect(data[:active_users]).not_to be_nil
      expect(data[:popular_blogs]).not_to be_nil
    end

    it 'returns correct activity data for 90 days' do
      data = AdminService.activity_data("90_days")
      expect(data[:daily_data]).not_to be_empty
      expect(data[:active_users]).not_to be_nil
      expect(data[:popular_blogs]).not_to be_nil
    end

    it 'returns correct activity data for 1 year' do
      data = AdminService.activity_data("year")
      expect(data[:daily_data]).not_to be_empty
      expect(data[:active_users]).not_to be_nil
      expect(data[:popular_blogs]).not_to be_nil
    end
  end

  describe '.filter_users' do
    it 'filters users based on name' do
      filtered_users = AdminService.filter_users({ name: users.first.name })
      expect(filtered_users).to include(users.first)
    end

    it 'filters users based on email' do
      filtered_users = AdminService.filter_users(email: users.first.email)
      expect(filtered_users).to include(users.first)
    end

    it 'filters users based on role' do
      filtered_users = AdminService.filter_users(role: users.first.role)
      expect(filtered_users).to include(users.first)
    end

    it "filters users based on joined date" do
      filtered_users = AdminService.filter_users(joined: "7_days")
      expect(filtered_users).to include(*users)

      filtered_users = AdminService.filter_users(joined: "month")
      expect(filtered_users).to include(*users)

      filtered_users = AdminService.filter_users(joined: "3_months")
      expect(filtered_users).to include(*users)

      filtered_users = AdminService.filter_users(joined: "year")
      expect(filtered_users).to include(*users)
    end

    it "filters users based on search query" do
      filtered_users = AdminService.filter_users(search: users.first.name)
      expect(filtered_users).to include(users.first)
    end
  end

  describe '.filter_blogs' do
    it 'filters blogs based on title' do
      filtered_blogs = AdminService.filter_blogs(title: blogs.first.title)
      expect(filtered_blogs).to include(blogs.first)
    end

    it 'filters blogs based on author' do
      filtered_blogs = AdminService.filter_blogs(author: users.first.name)
      expect(filtered_blogs).to include(*blogs)
    end

    it 'filters blogs based on date range' do
      filtered_blogs = AdminService.filter_blogs(date_range: "7_days")
      expect(filtered_blogs).to include(*blogs)

      filtered_blogs = AdminService.filter_blogs(date_range: "month")
      expect(filtered_blogs).to include(*blogs)

      filtered_blogs = AdminService.filter_blogs(date_range: "3_months")
      expect(filtered_blogs).to include(*blogs)

      filtered_blogs = AdminService.filter_blogs(date_range: "year")
      expect(filtered_blogs).to include(*blogs)
    end

    it 'filters blogs based on search query' do
      filtered_blogs = AdminService.filter_blogs(search: blogs.first.title)
      expect(filtered_blogs).to include(blogs.first)
    end
  end

  describe '.find_user' do
    it 'returns a user when found' do
      result = AdminService.find_user(users.first.id)
      expect(result[:success]).to be true
      expect(result[:user]).to eq(users.first)
    end

    it 'returns error when user not found' do
      result = AdminService.find_user(0)
      expect(result[:success]).to be false
    end
  end

  describe '.find_blog' do
    it 'returns a blog when found' do
      result = AdminService.find_blog(blogs.first.id)
      expect(result[:success]).to be true
      expect(result[:blog]).to eq(blogs.first)
    end
  end

  describe '.update_user' do
    it 'updates user when valid params are provided' do
      user_params = { name: "Updated Name" }
      result = AdminService.update_user(users.first, user_params)
      expect(result[:success]).to be true
      expect(users.first.reload.name).to eq("Updated Name")
    end

    it 'returns error when invalid params are provided' do
      user_params = { email: "" }
      result = AdminService.update_user(users.first, user_params)
      expect(result[:success]).to be false
    end
  end

  describe '.create_blog' do
    it 'creates a new blog when valid params are provided' do
      blog_params = { title: "New Blog", content: "New Content" }
      result = AdminService.create_blog(blog_params, users.first)
      expect(result[:success]).to be true
      expect(Blog.last.title).to eq("New Blog")
    end

    it 'returns error when invalid params are provided' do
      blog_params = { title: "", content: "" }
      result = AdminService.create_blog(blog_params, users.first)
      expect(result[:success]).to be false
    end
  end

  describe '.update_blog' do
    it 'updates blog when valid params are provided' do
      blog_params = { title: "Updated Title" }
      result = AdminService.update_blog(blogs.first, blog_params)
      expect(result[:success]).to be true
      expect(blogs.first.reload.title).to eq("Updated Title")
    end

    it 'returns error when invalid params are provided' do
      blog_params = { title: "" }
      result = AdminService.update_blog(blogs.first, blog_params)
      expect(result[:success]).to be false
    end
  end

  describe '.destroy_blog' do
    it 'deletes the blog' do
      result = AdminService.destroy_blog(blogs.first)
      expect(result[:success]).to be true
    end
  end

  describe '.user_activity' do
    it 'returns correct user activity data' do
      data = AdminService.user_activity(users.first)
      expect(data[:blogs].count).to eq(users.first.blogs.count)
      expect(data[:comments].count).to eq(users.first.comments.count)
      expect(data[:likes].count).to eq(users.first.likes.count)
    end
  end

  describe '.generate_users_csv' do
    it 'generates a valid CSV file' do
      csv_content = AdminService.generate_users_csv(users)
      expect(csv_content).to include("ID,Name,Email,Role,Created At")
    end
  end

  describe '.generate_blogs_csv' do
    it 'generates a valid CSV file' do
      csv_content = AdminService.generate_blogs_csv(blogs)
      expect(csv_content).to include("ID,Title,Author,Comments,Likes,Created At")
    end
  end

  describe '.is_admin?' do
    it 'returns true if user is admin' do
      user = create(:user, role: "admin")
      expect(AdminService.is_admin?(user)).to be true
    end

    it 'returns false if user is not admin' do
      user = create(:user, role: "user")
      expect(AdminService.is_admin?(user)).to be false
    end
  end
end
