class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  has_and_belongs_to_many :roles
  has_many :scatter_downloads
#
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :city, :last_name, :first_name

  validates :city, :presence => true
  validates :last_name, :presence => true  
  validates :first_name, :presence => true 
     
  def role?(role)
      return !!self.roles.find_by_role(role.to_s.camelize)
  end
  
end

