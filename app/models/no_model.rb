class NoModel < ActiveRecord::Base
  attr_accessor :force_create
  attr_accessible :figure, :description, :figure_file_name
  belongs_to :experiment
  has_attached_file :figure, :path => ":rails_root/public/SAX_DATA/:data_directory/nomodel/:basename_nomodel.:extension" #, :styles => {:normal => '600x500'}
  validates_presence_of :description
  validates_attachment_content_type :figure, :content_type => ['image/jpeg', 'image/png', 'image/tiff'], :message => "Must be either png, tiff or jpeg"  
  validate :image_size, :unless => :force_create

  
  def image_size
    if figure && figure.queued_for_write[:original]
      dimensions = Paperclip::Geometry.from_file(figure.queued_for_write[:original])              
      
      self.errors.add(:figure, "Too wide, please upload a smaller file => width < 601 px") if dimensions.width > 601
      self.errors.add(:figure, "Too high, please upload a smaller file => height < 501 px") if dimensions.height > 501
    end
  end
  #
  # copy file to originals
  #
  
end
