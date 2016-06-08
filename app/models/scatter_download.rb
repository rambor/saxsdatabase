class ScatterDownload < ActiveRecord::Base
    attr_accessible :user_id, :ip_address, :institution, :country, :status, :version, :terms_of_service, :pi, :email
    
    belongs_to :user
    validates :user_id, :presence => true
    validates :institution, :presence => true
    validates :country, :presence => true
    validates :ip_address, :presence => true            
    validates :status, :presence => true # non-profit, academic, goverment, industry               
    validates :version, :presence => true                
    validates :terms_of_service, acceptance: true
  
end