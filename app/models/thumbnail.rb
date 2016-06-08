class Thumbnail < ActiveRecord::Base
  attr_accessor :data_directory
  attr_accessible :experiment_id, :data_directory, :thumbnail
  has_attached_file :thumbnail, :path => ":rails_root/public/SAX_DATA/:data_directory/low_res_thumbnail.:extension"  
  belongs_to :experiment
  
  Paperclip.interpolates :data_directory do |attachment, style|
    attachment.instance.data_directory
  end
  
end