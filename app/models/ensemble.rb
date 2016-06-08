class Ensemble < ActiveRecord::Base
  attr_accessor :pdbfiles, :fit_lines, :force_create, :format
  attr_accessible :pdbfiles, :scoring_function, :score, :selection_method, :simulation_method, :simulation_algorithm, :ensemble_size, :member_size, :fit_filename, 
  :diagnostic, :figure_legend, :diagnostic_file_name, :diagnostic_file_size, :diagnostic_content_type
  belongs_to :experiment
  has_attached_file :diagnostic 
  validates_presence_of :scoring_function, :selection_method, :simulation_algorithm, :fit_filename
  validates :figure_legend, :presence => true
  validates :score, :presence => true, :numericality => true
  validates :ensemble_size, :presence => true, :numericality => true
  validates :member_size, :presence => true, :numericality => true
#  validates :format, :unless => :force_create
  
  validates_attachment_presence :diagnostic
  validates_attachment_content_type :diagnostic, :content_type => ['image/jpeg', 'image/png', 'image/tiff'], :message => "Must be either png, tiff or jpeg"
  
  def format
    #
    # Validate the selected file has three columns of data before uploading
    #
    test = 0
    if !(fit_lines.nil?) 
      $count = 0
      $index = 0
      while $index < fit_lines.size            
        if fit_lines[$index] =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/ && fit_lines[$index].lstrip.chomp.split(/[\s\t]+/).size == 3
           #
           # run through until no long true
           #
           begin
             $count += 1             
             $index += 1
           end until $index > fit_lines.size || fit_lines[$index].nil? || fit_lines[$index] =~ !(fit_lines[$index].lstrip.chomp.split(/[\s\t]+/).size == 3) && !(fit_lines[$index] =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/)
        end  
        if $count > test
          test = $count
        end
        $index += 1        
      end
    else
        errors.add(:fit_lines, " :Empty array, need a file!")
    end
    #
    # Length Check
    #
    if test < 200 # Fit File check length - why 220 lines, seems reasonable for modern day detectors, usually get 500 data points.
        errors.add(:fit_lines, " :Incorrect file, must be a 3 column text file with at least 200 points.".html_safe)  
    end  
  end
  
  def self.presence_of?(attrib, value)
    mock = self.new(attrib => value )    
    if mock.pdbfiles.nil?
      return false
    else
      return true
    end
  end  
  
  def self.make_fit_plot(fit_lines, directory)
    #
    # write out 3 columns of data to temp file and delete after making plot
    #
    temppath = File.join(directory, 'temp.txt')    
    x_array = Array.new
    y_array = Array.new    
    fit_lines.each do |line|

      if line =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/ && line.lstrip.chomp.split(/[\s\t]+/).size >= 3 && line.lstrip.chomp.split(/[\s\t]+/)[1].to_f > 0
          open(temppath, 'a'){|f| f << line }
          temp_array = line.lstrip.split
          x_array << temp_array[0].to_f
          y_array << temp_array[1].to_f
      end
    end
    #
    # make Gnuplot
    #
    gnuplot_lines = Array.new
    x_array = x_array.sort
    y_array = y_array.sort

    domain_a = x_array[0]
    domain_b = x_array[x_array.length-1].to_f
    tic = (domain_b - domain_a)/4
    n = 1
    until tic*(10.to_f**n).to_i > 1
       n += 1 
    end

    range_a = y_array[1]
    range_b = y_array[y_array.length-1] + 0.10*y_array[y_array.length-1]
    ytics = range_b/2
    xtics =  (domain_b*10**1).round.to_f/10**1

    outpath = File.join(directory, 'med_res_ensemble_FIT.png')        
    gnupath = File.join(directory, 'temp.plt')        

    gnuplot_lines << "set terminal png nocrop size 386, 300\n"
    gnuplot_lines << "set encoding iso_8859_1\n"
    gnuplot_lines << "set output '#{outpath}'\n" 
    gnuplot_lines << "set xrange [#{domain_a} : #{domain_b}]\n"
    gnuplot_lines << "set yrange [#{range_a}: #{range_b}]\n"    
    gnuplot_lines << "set logscale y\n"
    gnuplot_lines << "set ytic auto nomirror\n"
    gnuplot_lines << "set xtics 0, #{(tic*10**1).round.to_f/10} nomirror\n"
    gnuplot_lines << "set xlabel \"q\" tc rgb '#494949'\n"
    gnuplot_lines << "set encoding default\n"
    gnuplot_lines << "set ylabel \"Intensity, log I(q)\" tc rgb '#494949'\n"
    gnuplot_lines << "set border 3\n"
    gnuplot_lines << "plot '#{temppath}' using 1:3 notitle with points pointtype 7 ps 1 lc rgb \"cyan\", '#{temppath}' using 1:2 notitle with points pointtype 7 ps 0.5 lc rgb \"red\" \n"

    open(gnupath, 'w') do |f|
        gnuplot_lines.each {|i| f << i }
    end
    
    command_code = "gnuplot #{gnupath}"
    system(command_code)
    File.delete(gnupath)    
    File.delete(temppath)    
  end
  
end
