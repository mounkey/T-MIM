class User < ApplicationRecord
  acts_as_tenant :account

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Roles: 0 = User, 1 = Admin
  enum :role, { user: 0, admin: 1 }

  # Validations
  validates :name, presence: true
  validates :run, presence: true, uniqueness: { scope: :account_id }
end
