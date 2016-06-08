class Expgene < ActiveRecord::Base
  attr_accessor :gene_count
  attr_accessible :abbr_name, :experimental_sequence, :annotation, :exp_mw, :gene_count, :pI, :gene_id  
  belongs_to :experiments
#  belongs_to :genes
  validates :experimental_sequence, :presence => true
  validates :annotation, :presence => true
  validates :exp_mw, :presence => true, :numericality => true  
  validates :abbr_name, :presence => true, :format =>  {:with => Regexp.new("[A-Za-z0-9]+")}, :length => {:minimum => 3, :maximum => 10}   
end