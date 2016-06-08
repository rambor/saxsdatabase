class Experiment < ActiveRecord::Base
  attr_accessor :model_check
  attr_accessible :pH, :salt_concentration, :salt, :buffer, :description, :data_directory, :title, :dmax, :rg, :rg_real, :sig_Rg_real, :io, :sig_Io, :iofq_file_name, :pofr_file_name,  
  :email, :bioisis_id, :source_location, :status, :publication, :experimental_details, :divalent, :divalent_concentration, :temp, :additives, :io_molecular_weight, :sig_Rg, :v_porod,  
  :volume_of_correlation, :porod_exponent, :protein, :rna, :dna, :membrane, :authors_attributes, :expgenes_attributes, :structural_model_attributes, :gasbor_results_attributes, :ensemble_attributes,
  :dammin_result_attributes, :no_model_attributes, :thumbnail_attributes
    
  # a single experiment can belong to more than one gene such as those involving heterocomplexes.
  # this requires a relational table with the following name experiments_genes (notice the plural)
  has_and_belongs_to_many :genes
  has_and_belongs_to_many :expgenes
  has_and_belongs_to_many :authors
  has_many :experimental_links, :dependent => :destroy
  has_many :link_to, :through => :experimental_links

  has_many :inverse_experimental_links, :class_name => "ExperimentalLink", :foreign_key => "link_to_id", :dependent => :destroy
  has_many :inverse_link_to, :through => :inverse_experimental_links, :source => :experiment
  has_one :thumbnail


  has_many :organisms
  has_one :dammin_result, :dependent => :destroy
  has_many :gasbor_results, :dependent => :destroy
  has_one :structural_model, :dependent => :destroy
  has_one :ensemble, :dependent => :destroy	
  has_one :no_model, :dependent => :destroy  

#  accepts_nested_attributes_for :thumbnail, :allow_destroy => true, :reject_if => proc { |attrs| !attrs.nil? }
  accepts_nested_attributes_for :thumbnail, :allow_destroy => true 
  accepts_nested_attributes_for :authors, :expgenes, :dammin_result, :gasbor_results, :structural_model, :ensemble, :no_model
  validates_uniqueness_of :bioisis_id, :allow_nil => true, :allow_blank => true      
  validates_presence_of :pH, :salt_concentration, :iofq_file_name, :pofr_file_name, :salt, :buffer, :description, :title, :source_location, :email, :message => "<font color=\"red\">Missing Required Field</font>"
  validates :io, :numericality => true, :presence => true  
  validates_presence_of :sig_Io, :message => "<font color=\"red\">Standard deviation of I(0) is missing!</font>"
  validates_presence_of :sig_Rg, :message => "<font color=\"red\">Standard deviation of Rg is missing!</font>"
  validates :v_porod, :presence => true, :numericality => {:greater_than => 1000}
  validates :dmax, :presence => true, :numericality => {:greater_than => 10}
  validates :io_molecular_weight, :presence => true, :numericality => {:greater_than => 1000}
  validates_numericality_of :rg, :greater_than => 5, :message =>"<font color=\"red\">must be greater than zero.</font>"  
  validates_numericality_of :salt_concentration, :rg_real, :sig_Rg, :sig_Rg_real, :message => "<font color=\"red\">This must be a number.</font>" 
  validate :model_check
  validate :gene_check
  
  with_options :if => Proc.new { |model| !(model.dammin_result.blank?) } do |dammin|
    dammin.validates_presence_of :dammin_result
    dammin.validates_associated :dammin_result
  end
  
  def gene_check
    unless expgenes.size > 0
      self.errors[:base] << "Need a Gene"
#      errors.add_to_base("need a gene")
      return false
    end
  end
    
  def model_check
    unless gasbor_results.size >= 1 or !dammin_result.nil? or !structural_model.nil? or !ensemble.nil?  or !no_model.nil?#this checks to make sure the user has provided either a dammin model or gasbor model
      self.errors[:base] << "You must specify one or more of the following models DAMMIN, GASBOR, STRUCTURAL, ENSEMBLE or NO Model with your SAXS data."
#      errors.add_to_base("You must specify one or more of the following models DAMMIN, GASBOR, STRUCTURAL, ENSEMBLE or NO Model with your SAXS data.")
      return false
    end   
  end
  
  def self.search(search)
    if search
      where('bioisis_id LIKE ?', "%#{search}%").limit(5)
    else
      scoped
    end
  end  
    
end
