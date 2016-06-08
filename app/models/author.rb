class Author < ActiveRecord::Base
  #  has_many :author_experiments
  #  has_many :experiments, :through => :author_experiments
  #  acts_as_ferret :fields => [:lastname], :remote => true
    before_save :remove_dots_change_case
    attr_accessible :lastname, :initials
    has_and_belongs_to_many :experiments
    validates  :lastname, 
              :presence => true, 
              :format => {:with => /^[A-Z][a-z]+[^0-9]/, :message => "Letters only please"}
              
              
    validates :initials, 
             :presence => true,
             :format => {:with => Regexp.new("^[A-Z]+")}

    def remove_dots_change_case
         self.initials.gsub!(/[\s\.]+/,"")  
         self.initials.upcase!
         self.lastname.capitalize!
    end
      
end
