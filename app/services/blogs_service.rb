class BlogsService
  def self.index(user)
    user.blogs.includes(:user).order(created_at: :desc)
  end

  def self.show(blog_id)
    begin
      blog = Blog.find(blog_id)
      comments = blog.comments.includes(:user).order(created_at: :desc)
      { blog: blog, comments: comments, success: true }
    rescue ActiveRecord::RecordNotFound => e
      { success: false, error: "Blog not found." }
    end
  end

  def self.create(user, blog_params)
    blog = user.blogs.build(blog_params)

    if blog.save
      { blog: blog, success: true }
    else
      { blog: blog, success: false }
    end
  end

  def self.update(blog, blog_params)
    if blog.update(blog_params)
      { blog: blog, success: true }
    else
      { blog: blog, success: false }
    end
  end

  def self.destroy(blog)
    blog.destroy
    { success: true }
  end

  def self.owner?(blog, user)
    blog.user == user
  end

  def self.fetch(blog_id)
    begin
      blog = Blog.find(blog_id)
      { blog: blog, success: true }
    rescue ActiveRecord::RecordNotFound => e
      { success: false, error: "Blog not found." }
    end
  end
end
