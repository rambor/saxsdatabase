class ScatterUpdate < ActiveRecord::Base
  attr_accessor :email_users
  
  attr_accessible :comments, :version, :title, :zipfile, :email_users

  validates_presence_of :comments, :version, :title
  validates :zipfile, :attachment_presence => true
  has_attached_file :zipfile, :path => ":rails_root/public/scatter.zip"
  validates_attachment_content_type :zipfile, :content_type => 'application/zip'      
  
end
