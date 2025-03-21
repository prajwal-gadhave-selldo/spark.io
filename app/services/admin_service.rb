require "csv"

class AdminService
  def self.dashboard_data
    # Get counts for the dashboard cards
    total_users = User.count
    total_blogs = Blog.count
    total_comments = Comment.count
    total_likes = Like.count

    # Get new users in the last 30 days
    new_users_count = User.where("created_at >= ?", 30.days.ago).count

    # Get data for user growth chart (last 12 months)
    user_growth_data = 12.downto(0).map do |i|
      month = i.months.ago.beginning_of_month
      {
        month: month.strftime("%b %Y"),
        count: User.where("created_at <= ? AND created_at >= ?", month.end_of_month, month).count
      }
    end

    content_data = 12.downto(0).map do |i|
      month = i.months.ago.beginning_of_month
      {
        month: month.strftime("%b %Y"),
        blogs: Blog.where("created_at <= ? AND created_at >= ?", month.end_of_month, month).count,
        comments: Comment.where("created_at <= ? AND created_at >= ?", month.end_of_month, month).count
      }
    end

    latest_users = User.order(created_at: :desc).limit(5)
    latest_blogs = Blog.includes(:user).order(created_at: :desc).limit(5)

    {
      total_users: total_users,
      total_blogs: total_blogs,
      total_comments: total_comments,
      total_likes: total_likes,
      new_users_count: new_users_count,
      user_growth_data: user_growth_data,
      content_data: content_data,
      latest_users: latest_users,
      latest_blogs: latest_blogs
    }
  end

  def self.activity_data(date_range)
    case date_range
    when "7_days"
      start_date = 7.days.ago
    when "90_days"
      start_date = 90.days.ago
    when "year"
      start_date = 1.year.ago
    else
      start_date = 30.days.ago
    end

    daily_data = (start_date.to_date..Date.today).map do |date|
      next_date = date + 1.day
      {
        date: date.strftime("%b %d"),
        users: User.where("created_at >= ? AND created_at < ?", date.beginning_of_day, next_date.beginning_of_day).count,
        blogs: Blog.where("created_at >= ? AND created_at < ?", date.beginning_of_day, next_date.beginning_of_day).count,
        comments: Comment.where("created_at >= ? AND created_at < ?", date.beginning_of_day, next_date.beginning_of_day).count,
        likes: Like.where("created_at >= ? AND created_at < ?", date.beginning_of_day, next_date.beginning_of_day).count
      }
    end

    active_users = User
      .left_joins(:blogs, :comments, :likes)
      .where(
        "blogs.created_at >= :start_date OR
         comments.created_at >= :start_date OR
         likes.created_at >= :start_date OR
         users.created_at >= :start_date",
        start_date: start_date
      )
      .select(
        "users.id,
         users.name,
         users.email,
         COUNT(DISTINCT blogs.id) as blog_count,
         COUNT(DISTINCT comments.id) as comment_count,
         COUNT(DISTINCT likes.id) as like_count"
      )
      .group(:id, :name, :email)
      .order(Arel.sql("(COUNT(DISTINCT blogs.id) + COUNT(DISTINCT comments.id) + COUNT(DISTINCT likes.id)) DESC"))
      .limit(10)

    popular_blogs = Blog
      .left_joins(:comments, :likes)
      .select(
        "blogs.id,
        blogs.title,
        blogs.created_at,
        COUNT(DISTINCT comments.id) as comment_count,
        COUNT(DISTINCT likes.id) as like_count"
      )
      .where("blogs.created_at >= ?", start_date)
      .group(:id, :title, :created_at)
      .order(Arel.sql("(COUNT(DISTINCT comments.id) + COUNT(DISTINCT likes.id)) DESC"))
      .limit(5)

    {
      start_date: start_date,
      daily_data: daily_data,
      active_users: active_users,
      popular_blogs: popular_blogs
    }
  end

  def self.filter_users(params)
    users = User.all.order(created_at: :desc)

    # Apply filters if present
    users = users.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    users = users.where("email ILIKE ?", "%#{params[:email]}%") if params[:email].present?
    users = users.where(role: params[:role]) if params[:role].present?
    users = users.where(status: params[:status]) if params[:status].present?

    case params[:joined]
    when "7_days"
      users = users.where("created_at >= ?", 7.days.ago)
    when "month"
      users = users.where("created_at >= ?", 1.month.ago)
    when "3_months"
      users = users.where("created_at >= ?", 3.months.ago)
    when "year"
      users = users.where("created_at >= ?", 1.year.ago)
    end

    if params[:search].present?
      users = users.where("name ILIKE :query OR email ILIKE :query", query: "%#{params[:search]}%")
    end

    users.order(created_at: :desc)
  end

  def self.filter_blogs(params)
    blogs = Blog.includes(:user, :comments, :likes).order(created_at: :desc)

    # Apply filters if present
    blogs = blogs.where("title ILIKE ?", "%#{params[:title]}%") if params[:title].present?
    blogs = blogs.joins(:user).where("users.name ILIKE ?", "%#{params[:author]}%") if params[:author].present?
    blogs = blogs.where(status: params[:status]) if params[:status].present?

    case params[:date_range]
    when "7_days"
      blogs = blogs.where("blogs.created_at >= ?", 7.days.ago)
    when "month"
      blogs = blogs.where("blogs.created_at >= ?", 1.month.ago)
    when "3_months"
      blogs = blogs.where("blogs.created_at >= ?", 3.months.ago)
    when "year"
      blogs = blogs.where("blogs.created_at >= ?", 1.year.ago)
    end

    # Handle search query
    if params[:search].present?
      blogs = blogs.where("title ILIKE :query OR content ILIKE :query", query: "%#{params[:search]}%")
    end

    blogs.order(created_at: :desc)
  end

  def self.find_user(id)
    begin
      user = User.find(id)
      { user: user, success: true }
    rescue ActiveRecord::RecordNotFound => e
      { success: false, error: "User not found." }
    end
  end

  def self.find_blog(id)
    begin
      blog = Blog.find(id)
      { blog: blog, success: true }
    rescue ActiveRecord::RecordNotFound => e
      { success: false, error: "Blog not found." }
    end
  end

  def self.update_user(user, user_params)
    if user.update(user_params)
      { user: user, success: true }
    else
      { user: user, success: false }
    end
  end

  def self.create_blog(blog_params, current_user)
    blog = Blog.new(blog_params)
    blog.user = current_user

    if blog.save
      { blog: blog, success: true }
    else
      { blog: blog, success: false }
    end
  end

  def self.update_blog(blog, blog_params)
    if blog.update(blog_params)
      { blog: blog, success: true }
    else
      { blog: blog, success: false }
    end
  end

  def self.destroy_blog(blog)
    blog.destroy
    { success: true }
  end

  def self.user_activity(user)
    blogs = user.blogs.order(created_at: :desc)
    comments = user.comments.includes(:blog).order(created_at: :desc)
    likes = user.likes.includes(:blog).order(created_at: :desc)

    {
      blogs: blogs,
      comments: comments,
      likes: likes
    }
  end

  def self.is_admin?(user)
    user&.role == "admin"
  end

  def self.generate_users_csv(users)
    headers = [ "ID", "Name", "Email", "Role", "Created At" ]

    CSV.generate(headers: true) do |csv|
      csv << headers

      users.each do |user|
        csv << [
          user.id,
          user.name,
          user.email,
          user.role,
          user.created_at.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end
  end

  def self.generate_blogs_csv(blogs)
    headers = [ "ID", "Title", "Author", "Comments", "Likes", "Created At" ]

    CSV.generate(headers: true) do |csv|
      csv << headers

      blogs.each do |blog|
        csv << [
          blog.id,
          blog.title,
          blog.user.name,
          blog.comments.count,
          blog.likes.count,
          blog.created_at.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end
  end
end
