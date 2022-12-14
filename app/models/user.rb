class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest

  has_many :microposts, dependent: :destroy
  has_many :microposts, dependent: :destroy
  has_many :following_a_user, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :following_a_user, source: :followed
  has_many :followed_by_others, class_name: "Relationship", foreign_key: "followed_id",
dependent: :destroy
  has_many :followers, through: :followed_by_others, source: :follower

  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  has_secure_password

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end
  
  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Returns all microposts for this User
  def feed
    Micropost.where("
      user_id IN (
        SELECT followed_id
        FROM relationships
        WHERE follower_id = :user_id
      )
      OR user_id = :user_id
    ", user_id: id)
  end

  # Follows a user.
  def follow(user_being_followed)
    following << user_being_followed
  end
  
  # Unfollows a user.
  def unfollow(user_being_followed)
    following.delete(user_being_followed)
  end
  
  # Returns true if the current user is following the other user.
  def following?(user_being_followed)
    following.include?(user_being_followed)
  end


  private
    def downcase_email
      email.downcase!
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
