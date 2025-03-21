class AuthHelper
  def self.authenticate(user)
    token = JWT.encode({ id: user.id, email: user.email, exp: 24.hours.from_now.to_i }, "tempjwtsalt")
    { Cookie: "jwt=#{token}" }
  end
end
