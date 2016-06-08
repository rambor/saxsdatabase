module UploadPofr
  
    def check_gnom(file_lines)
      # check the array for at least three elements
      # G N O M
      # R P(R) ERROR
      # Distance Distribution
      test = file_lines.select{|v| v =~ /(G N O M)|(R[\s\t]+P\(R\)[\s\t]+ERROR)|(Distance[\s\t]+[Dd]istribution[\s\t]+function)/}
      if test.size == 3
        return true
      else
        return false
      end      
    end
    
    def check_format(line)
      truthy = false
      if line =~ /([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+([0-9]\.[0-9]+E[\+\-]?[0-9]+)|([0-9]+\.[0-9]+)[\s\t]?+/i
        truthy = true
      end    
      return truthy
    end    

    def upload_POFR(directory, subdirectory, uploaded_file, new_file_name)
      name = uploaded_file.original_filename.gsub( /[^a-zA-Z0-9_\.]/, '_') 
      path = File.join(subdirectory, name+".pofr")
      newpath = File.join(directory, new_file_name+".dat")
      #
      # Make directory if it does not exist
      #
      if !File.directory? subdirectory
        Dir.mkdir(subdirectory)  
      end
      #
      # Write original uploaded file to upload directory
      #
      File.open(path, "w"){|f| f.write(uploaded_file.read)}
      # 
      # Open file, and read in the lines that match data format and write to pofr_file_name    
      #
      file_lines = Array.new
      open(path){|f| file_lines = f.readlines }
      #
      # if GNOM file, must find index of above and grab lines following R, P(R) adn ERROR 
      #
      xData=[]
      
      pofr_lines = Array.new      
      if check_gnom(file_lines)
        line = file_lines.select{|v| v =~ /R[\s\t]+P\(R\)[\s\t]+ERROR/i}
        if line.size == 1
          index = file_lines.index(line[0]) + 1
          while index < file_lines.size
            if check_format(file_lines[index]) && file_lines[index].lstrip.chomp.split(/[\s\t]+/).size == 3
              pofr_lines << file_lines[index]
              xData << file_lines[index].strip.split(/[\s\t]+/)[0].to_f
            end
            index += 1
          end
          
        end
      else  
        #
        # if not GNOM, it is a 3 column text fle
        #          
        file_lines.each do |line|
          if check_format(line) && line.lstrip.chomp.split(/[\s\t]+/).size == 3
            pofr_lines << line
            xData << file_lines[index].strip.split(/[\s\t]+/)[0].to_f            
          end      
        end
      end
      
      if (xData.max < 10) # r must be in Angstroms, if true, assume nm and divide by 10        
        pofr_lines.each_with_index do |line, index|
          values = line.strip.split(/[\s\t]+/)          
          pofr_lines[index] = "#{values[0].to_f/10} #{values[1]} #{values[2]}"
        end        
      end
      
      #
      # Write out pofr_lines to pofr_file_name
      #      
      open(newpath, 'w') do |f|
        pofr_lines.each {|i| f << i }
      end
      #
      # Make Graph
      #
      x_array = Array.new
      y_array = Array.new   
      gnuplot_lines = Array.new
         
      pofr_lines.each do |x|
        temp_array = x.lstrip.split
        x_array << temp_array[0].to_f
        y_array << temp_array[1].to_f
      end

      domain_a = x_array[0]
      domain_b = x_array[x_array.length-1]

      range_a = y_array[1]
      range_b = y_array[y_array.length-1] + 0.10*y_array[y_array.length-1]
      ytics = range_b/2
      xtics =  domain_b.round.to_f/10**1
      
      outpath = File.join(directory, 'med_res_PofR.png')    
      gnupath = File.join(directory, 'med_res_PofR.plt')              
      
      gnuplot_lines << "set terminal png nocrop size 386, 300\n"
      gnuplot_lines << "set encoding iso_8859_1\n"       
      gnuplot_lines << "set output '#{outpath}'\n" 
      gnuplot_lines << "set xrange [#{domain_a} : #{domain_b}]\n"
      gnuplot_lines << "set ytics auto nomirror\n"      
      gnuplot_lines << "set xtics auto nomirror\n"            
      gnuplot_lines << "set noytics \n"
#      gnuplot_lines << "set xtics auto\n"
      gnuplot_lines << "set xlabel \"r, (\\305)\"\n"
      gnuplot_lines << "set ylabel \"P(r)\"\n"
      gnuplot_lines << "unset border\n"
      gnuplot_lines << "set border 3\n"
      gnuplot_lines << "plot '#{newpath}' using 1:2 notitle with lines lw 2 lc rgb '#24bf36'\n"
      open(gnupath, 'w') do |f|
         gnuplot_lines.each {|i| f << i }
      end
      
      command_code = "gnuplot #{gnupath}"
      system(command_code)
      File.delete(gnupath)
      
          
    end   
end