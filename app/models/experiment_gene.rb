class ExperimentGene < ActiveRecord::Base
  belongs_to :experiment
  belongs_to :gene
end