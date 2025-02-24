class UserPolicy < ApplicationPolicy
  def index?
    user.present? && user.role == "admin"
  end

  def show?
    user.present? && user.role == "admin"
  end

  def update?
    user.present? && user.role == "admin"
  end

  def activity?
    user.present? && user.role == "admin"
  end
end
