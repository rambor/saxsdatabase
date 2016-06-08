class ExperimentExpgene < ActiveRecord::Base
  belongs_to :experiment
  belongs_to :expgene
end
