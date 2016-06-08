class News < ActiveRecord::Base
  attr_accessible :title, :category, :journal_info, :abstract, :link, :notes, :user_id
  belongs_to :user
  validates :title, :presence => true
end
