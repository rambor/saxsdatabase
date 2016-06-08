class DamminResult < ActiveRecord::Base
  belongs_to :experiment
  attr_accessible :spacegroup, :single_model_filename, :average_model_filename, :nsd, :sig_NSD, :number_in_average, :subcomb_model
  validates :nsd, :presence => true, :numericality => true
  validates :sig_NSD, :presence => true, :numericality => true
  validates :single_model_filename, :presence => true
  validates :average_model_filename, :presence => true
end