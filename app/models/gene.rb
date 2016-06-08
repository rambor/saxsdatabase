class Gene < ActiveRecord::Base
  attr_accessible :abbr_name, :experimental_sequence, :annotation
#  acts_as_ferret :fields => [:locus_name, :annotation, :organism_name, :abbreviation], :remote => true
  has_and_belongs_to_many :experiments
  belongs_to :organism
 # has_many :expgenes, :through => :expgenes_genes

#  def to_label
#    locus_name
#  end
   
  def organism_name
      return "#{self.organism.species}"
  end
  
  def abbreviation
      return "#{self.organism.abbreviation}"
  end

end
