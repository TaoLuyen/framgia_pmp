class User < ActiveRecord::Base
  attr_accessor :reset_token
  has_many :assignees
  has_many :tasks
  has_many :projects, foreign_key: :manager_id
  has_many :sprints, through: :assignees
  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :validatable

  USER_ATTRIBUTES_PARAMS = [:name, :email, :password, :password_confirmation]
  PASSWORD_ATTRIBUTES_PARAMS = [:password, :password_confirmation]

  enum role: [:member, :leader, :manager]

  validates :name, presence: true, length: {maximum: 50}

  before_create :set_default_role

  scope :fitler_by_role_not_manager, ->{where.not role: 2}

  def create_invite_digest
    self.reset_token = SecureRandom.urlsafe_base64(64)
    update_attributes(reset_password_token: reset_token,
      reset_password_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.invite_user(self).deliver_now
  end

  def is_user? user
    self == user
  end

  private
  def set_default_role
    self.role ||= :member
  end
end
