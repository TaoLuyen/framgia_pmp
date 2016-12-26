class Project < ActiveRecord::Base
  belongs_to :manager, class_name: User.name

  has_many :sprints
  has_many :product_backlogs
  has_many :assignees
  has_many :users, through: :members
  has_many :project_phases
  has_many :phases, through: :project_phases
  has_many :phase_items, through: :phases
  has_many :item_performances, through: :phase_items
  has_many :members, class_name: ProjectMember.name, foreign_key: :project_id

  enum status: [:init, :in_progress, :finish, :close]

  after_create :create_product_backlog, :update_status

  DEFAULT_PRODUCT_BACKLOG = 10
  PROJECT_ATTRIBUTES_PARAMS = [:name, :description, :start_date,
    :end_date]

  validate :check_end_date, on: [:create, :update]

  delegate :name, to: :manager, prefix: true, allow_nil: true

  scope :is_not_closed, ->{where.not status: 3}

  def managers
    self.members.where(role: 0)
  end

  def developers
    self.members.where(role: 1)
  end

  def reporters
    self.members.where(role: 2)
  end

  def reviewers
    self.members.where(role: 3)
  end

  def temps
    self.members.where(role: 4)
  end

  def include_assignee? current_user
    self.members.map(&:user_id).include? current_user.id
  end

  private
  def check_end_date
    if self.start_date.present? && self.end_date < self.start_date
      errors.add :end_date, I18n.t("errors.wrong_end_date")
    end
  end

  def update_status
    if self.start_date.present? && self.start_date < Date.today
      status = :in_progress
    else
      status = :init
    end
    self.update_attributes status: status
  end

  def create_product_backlog
    DEFAULT_PRODUCT_BACKLOG.times do
      ProductBacklog.create(project_id: self.id)
    end
  end
end
