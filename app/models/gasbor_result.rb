class GasborResult < ActiveRecord::Base
  attr_accessible :spacegroup, :nsd, :sig_NSD, :chi_square, :sig_chi_square, :number_in_average, :average_model_filename, :single_model_filename, :subcomb_model
  belongs_to :experiment
  validates_presence_of :chi_square, :nsd, :single_model_filename, :average_model_filename  
  
end
