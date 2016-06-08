class Submission < ActiveRecord::Base  
  include UploadPofr
  include LineFit
  belongs_to :user

  attr_accessor :data_lines, :datafile, :force_create
  attr_accessible :datafile, :data_directory, :email, :editing_count, :status, :user_id, :diagnostic, :nomodel, :bioisis_id, :force_create, :data_lines
  
  has_attached_file :diagnostic, :path => ":rails_root/public/SAX_DATA/:data_directory/ensemble/diagnostic.:extension"
  has_attached_file :nomodel, :path => ":rails_root/public/SAX_DATA/:data_directory/nomodel/nomodel.:extension", :url => "/SAX_DATA/:data_directory/nomodel/nomodel.:extension"
  validates :data_directory, :uniqueness => true
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"
  validate :format, :unless => :force_create

  def format
    #
    # Validate the selected file has three columns of data before uploading
    # 
    if !(data_lines.nil?) && !(check_gnom(data_lines)) # not a GNOM file

      @data_length = Array.new
      $count = 0
      test = 0
      $index = 0
      while $index < data_lines.size            
        if check_format(data_lines[$index]) && data_lines[$index].lstrip.chomp.split(/[\s\t]+/).size >= 3 && data_lines[$index].lstrip.chomp.split(/[\s\t]+/).size <= 4 
           #
           # run through until no long true
           #
           begin
             $count += 1             
             $index += 1
           end until $index > data_lines.size || data_lines[$index].nil? 
        end  
        if $count > test
          test = $count
        end
        $index += 1        
      end
                    
    elsif !(data_lines.nil?) && check_gnom(data_lines)
      #
      # Validate format and count pofr lines
      # Go to line where PofR data starts and check subsequent lines
      # Find line with R, P(R), and ERROR
      line = data_lines.select{|v| v =~ /R[\s\t]+P\(R\)[\s\t]+ERROR/i}
      if line.size == 1
        #
        # find index
        #
        $index = data_lines.index(line[0])
        $count = 0
        test = 0
        
        while $index < data_lines.size                                     
          if check_format(data_lines[$index]) && data_lines[$index].lstrip.chomp.split(/[\s\t]+/).size == 3
             #
             # run through until no longer true
             #
             begin
               $count += 1             
               $index += 1               
             end until ($index > data_lines.size || !check_format(data_lines[$index]) )
          end
            
          if $count > test
            test = $count
          end
          
          $index += 1        
        end
      else        
        errors.add(:data_lines, " :Improper Gnom File")
      end                
    else
        errors.add(:data_lines, " :Empty array, need a file!")
    end
    #
    # Length Check
    #
    if !(data_lines.nil?) && !(check_gnom(data_lines)) && test < 90 # IofQ check length - why 220 lines, seems reasonable for modern day detectors, usually get 500 data points.
        errors.add(:data_lines, " :Incorrect file, must be a 3 column text file with at least 90 points: You have #{data_lines.size}.".html_safe)  
    elsif !(data_lines.nil?) && check_gnom(data_lines) && test < 50 # PofR check length
        errors.add(:data_lines, " :Incorrect file, must be a 3 column text file with at least 50 points.".html_safe)        
    end  
  end

  Paperclip.interpolates :data_directory do |attachment, style|
    attachment.instance.data_directory
  end

  def self.presence_of?(attrib, value)
    mock = self.new(attrib => value )    
    if mock.datafile.nil?
      return false
    else
      return true
    end
  end

  # Class Method (not instance method)
  def self.uploadINT(directory, subdirectory, uploaded_file, new_file_name, isNM)
    name = uploaded_file.original_filename.gsub( /[^a-zA-Z0-9_\.]/, '_')
    path = File.join(subdirectory, name+".int")
    newpath = File.join(directory, new_file_name+".dat")        
    #
    if !File.directory? subdirectory
      Dir.mkdir(subdirectory)  
    end
    #
    # Write original uploaded file to upload directory
    #
    if (isNM)
      # write modified file with nm converted to Angstrom
      File.open(path, "w"){|f| f.write(uploaded_file.read)} # if isNM is true, 
      
      tempLines =[]
      File.open(path){|x| tempLines = x.readlines}
      
      tempLines.each_with_index do |k,l|        
        if self.new.check_int_format(k) && !(k =~ /[a-z=]+/)
          x, y, z = k.strip.split(/[\s\t]+/)                    
          # get number of significant figures
          n = x.to_f.to_s.length - 1
          tempLines[l] = sprintf("%.#{n}E\t#{y} #{z}\n", x.to_f/10)
        end                
      end      
      
      File.open(path, "w"){|f| tempLines.each{|dd| f << dd}}            
    else
      File.open(path, "w"){|f| f.write(uploaded_file.read)} # if isNM is true, 
    end
    #
    # if file exists, want to add to it for making GNUPLOT multiplot
    #
    file_lines = Array.new
    # 
    # Open file, and read in the lines that match data format and write to iofq_file_name    
    #
    open(path){|f| file_lines = f.readlines }
    selected = Array.new
    file_lines.each do |f|
      data = f.strip!
      f.gsub!(/e/,"E")
      data = f.strip.split(/[\s\t]+/)
      if self.new.check_int_format(f) && !(f =~ /[a-z=]+/)
        if data[1].to_f > 0
           selected << f+"\n" 
        end         
      end      
    end
    
    #
    # If file exists, open file and write the contents to existing iofq_data_file
    # 
    # Delete current iofq_data_file, read in *.int files, make new file and plot
    #
    if File.exists? newpath # this means iofq_data_file exists
      #
      selected.insert(0,"\n# Following corresponds to: #{name}\n\n")
      #
      # append current iofq_data_file
      #
      open(newpath, 'a') do |f|
        selected.each {|i| f << i.chomp + "\n" }
      end
      
    elsif new_file_name =~ /iofq_data_file/ && !(File.exists? newpath) # this means iofq_data_file does not exist, new entry
      # over write any existing file
      open(newpath, 'w') do |f|
        selected.each {|i| f << i.chomp  + "\n" }
      end      
    end 
    #
    # Make the Gnuplot the data
    #
    data_lines = Array.new
    x_array = Array.new
    y_array = Array.new
    gnuplot_lines = Array.new

    #data_lines is an array where each line contains both the x and y data as a string

    open(newpath) {|f| data_lines = f.readlines }

    data_lines.each do |x| 
      if self.new.check_int_format(x) # make instance of self to access instance method
        temp_array = x.split
        x_array << temp_array[0].to_f
        y_array << temp_array[1].to_f
      end
    end

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

    outpath = File.join(directory, 'med_res_IofQ.png')        
    gnupath = File.join(directory, 'med_res_IofQ.plt')        

    gnuplot_lines << "set terminal png nocrop size 386, 300\n"
    gnuplot_lines << "set encoding iso_8859_1\n"
    gnuplot_lines << "set output '#{outpath}'\n" 
    gnuplot_lines << "set xrange [#{domain_a} : #{domain_b}]\n"
    gnuplot_lines << "set logscale y\n"
    gnuplot_lines << "set ytic auto nomirror\n"
    gnuplot_lines << "set xtics 0, #{(tic*10**1).round.to_f/10} nomirror\n"
    gnuplot_lines << "set xlabel \"q\" tc rgb '#494949'\n"
    gnuplot_lines << "set encoding default\n"
    gnuplot_lines << "set ylabel \"Intensity, log I(q)\" tc rgb '#494949'\n"
    gnuplot_lines << "set border 3\n"
    gnuplot_lines << "plot '#{newpath}' using 1:2:(column(-2)) notitle with points pointtype 7 ps 0.5 lc variable \n"

    open(gnupath, 'w') do |f|
        gnuplot_lines.each {|i| f << i }
    end     
    command_code = "gnuplot #{gnupath}"
    system(command_code)
    File.delete(gnupath)
    #
    # make Kratky plot
    #
    outpath = File.join(directory, 'med_res_kratky.png')            
    gnupath = File.join(directory, 'med_res_Kratky.plt')
    gnuplot_lines = Array.new
    
    gnuplot_lines << "set terminal png nocrop size 386, 300\n"
    gnuplot_lines << "set output '#{outpath}'\n" 
    gnuplot_lines << "set xrange [#{domain_a} : #{domain_b}]\n"
    #gnuplot_lines << "set yrange [#{range_a} : #{range_b}]\n"
    gnuplot_lines << "set ytics auto nomirror\n"
    gnuplot_lines << "set xtics 0, #{(tic*10**1).round.to_f/10} nomirror\n"
    gnuplot_lines << "set xlabel \"q\" font \"times, 14\" tc rgb '#494949' \n"
    gnuplot_lines << "set ylabel \"I(q) * q^2\" font \"times, 14\" tc rgb '#494949' \n"
    gnuplot_lines << "set border 3\n"
    gnuplot_lines << "plot '#{newpath}' using 1:($1*$1*$2):(column(-2)) notitle with points pointtype 3 pointsize 0.4 lc variable\n"

    open(gnupath, 'w') do |f|
       gnuplot_lines.each {|i| f << i }
    end    
    
    command_code = "gnuplot #{gnupath}"
    system(command_code)
    File.delete(gnupath)
    #
    # make low_res_IofQ.png
    #
    outpath = File.join(directory, 'low_res_IofQ.png')            
    gnupath = File.join(directory, 'med_res_IofQ.plt')
    gnuplot_lines = Array.new
    
    gnuplot_lines << "set terminal png nocrop size 150, 150\n"
    gnuplot_lines << "set output '#{outpath}'\n" 
    gnuplot_lines << "set xrange [0: #{domain_b}]\n"
    # gnuplot_lines << "set yrange [#{range_a} : #{range_b}]\n"
    gnuplot_lines << "set logscale y\n"
    gnuplot_lines << "unset ytics \n"
    gnuplot_lines << "unset xtics \n"
    # gnuplot_lines << "set xlabel \"q\" font \"times, 10\" tc rgb '#494949' \n"
    # gnuplot_lines << "set ylabel \"log I(q)\" font \"times, 10\" tc rgb '#494949' \n"
    gnuplot_lines << "set border 3\n"
    gnuplot_lines << "plot '#{newpath}' using 1:2:(column(-2)) notitle with points pointtype 7 ps 0.5 lc variable \n"        

    open(gnupath, 'w') do |f|
       gnuplot_lines.each {|i| f << i }
    end
    command_code = "gnuplot #{gnupath}"
    system(command_code)
    File.delete(gnupath)    
    
  end
  
  def self.make_Guinier(directory, functions, temp)
    gnuplot_lines = Array.new  
    functionline = String.new
    functions.each_pair do |key, value|
      gnuplot_lines << "#{value}\n"
      functionline = "#{functionline}, #{key} notitle lw 2 lc rgb '#000000'"
    end    
    #
    # open temp, read in to determine max and min values on x-axis
    #
    data = Array.new
    x_data = Array.new
    y_data = Array.new
    open(temp){|f| data = f.readlines}
    data.each do |line|
      if line =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/i && !(line =~ /[a-z=]+/)
        x_data << line.split(/[\s\t]+/)[0].to_f
        y_data << line.split(/[\s\t]+/)[1].to_f        
      end
    end
    ytic = (y_data.sort[y_data.size-1] - y_data.sort[0])/3 
    tic = (x_data.sort[x_data.size-1] - x_data.sort[0])/3

    n = 1
    until tic*(10.to_f**n).to_i > 1
      n += 1 
    end    
        
    outpath = File.join(directory, 'med_res_guinier.png')            
    gnupath = File.join(directory, 'med_res_Guinier.plt')    
    gnuplot_lines << "set terminal png nocrop size 386, 300\n"
    gnuplot_lines << "set output '#{outpath}'\n" 
    gnuplot_lines << "unset ytics\n"
    gnuplot_lines << "set xrange [#{x_data.sort[0]} : #{x_data.sort[x_data.size-1]}]\n"    
    gnuplot_lines << "set xtics 0, #{(tic*10**n).round.to_f/10**n} nomirror\n"
    gnuplot_lines << "set xlabel \"q^2\" font \"times, 14\" \n"
    gnuplot_lines << "set ylabel \"ln I(q) \" font \"times, 14\" \n"
    gnuplot_lines << "set border 3\n"
    gnuplot_lines << "plot '#{temp}' using 1:2:(column(-2)) notitle with points pointtype 7 ps 1 lc variable #{functionline} \n"    
    open(gnupath, 'w') do |f|
       gnuplot_lines.each {|i| f << i }
    end
    command_code = "gnuplot #{gnupath}"
    system(command_code)
    File.delete(gnupath)
    File.delete(temp)      
  end  
  
  # Class method
  def check_int_format(x)
    return check_format(x)
  end
    
  private
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end 
  

  
end
