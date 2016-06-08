class ExperimentalLink < ActiveRecord::Base
  
  belongs_to :experiment
  belongs_to :link_to, :class_name => "Experiment"
end
