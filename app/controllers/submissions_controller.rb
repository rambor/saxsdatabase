class SubmissionsController < ApplicationController 
   before_filter :authenticate_user!
   include FromFile
   include ToFile
   include IofqFilename
   include UploadPofr   
   include Calculations
   include LineFit
   #
   # New requires email and will send an email to creater with form.pdf
   #
   # Creates a directory (UNIX time stamp), and entries in Submission table
   #
   # Table will have email, editing_count directory, created on, updated on and status
   #
   # Load info into directory and not database but need validation
   #
   def new
     #
     # Grab the directory number in link from email, check against email address and code in link
     #
     # Open page and load from directory
     #
     @submission = Submission.new
     #
     # create originals directory
     #
     respond_to do |format|
       format.html # new.html.erb
     end
   end
   
   def save_and_exit
     #
     # Write contents to file, send an email and redirect user
     #
     @submission = Submission.find_by_data_directory(params[:id])     
     Notifier.save_and_exit(@submission).deliver
     respond_to do |format|
       format.text {render 'save_and_exit'}
       format.html 
     end     
   end
   
   def edit
     #
     # Open summary.txt if it exists and read in information
     #
     @experiment = Experiment.new

     @submission = Submission.find_by_data_directory(params[:id])
     #
     data_file = Rails.root.join("public", "SAX_DATA",@submission.data_directory, "summary.txt")

      if File.exists? data_file
        #
        # Open summary.txt and read in for filling in form
        #
        data_lines = Array.new
        open(data_file){|f| data_lines = f.readlines}
        @experiment = build_experiment(data_lines, @submission.data_directory)         
      end
      
      @experiment.email = @submission.email 
      if !@experiment.ensemble.nil?
         @experiment.ensemble.force_create = true
         @experiment.ensemble.diagnostic_file_name = @submission.diagnostic_file_name
         @experiment.ensemble.diagnostic_content_type = @submission.diagnostic_content_type
         @experiment.ensemble.diagnostic_file_size = @submission.diagnostic_file_size
      end

      if !@experiment.structural_model.nil?
         @experiment.structural_model.force_create = true
      end

      if !@experiment.no_model.nil?
         @experiment.no_model.force_create = true
         @experiment.no_model.figure_file_name = @submission.nomodel_file_name
         @experiment.no_model.figure_content_type = @submission.nomodel_content_type
         @experiment.no_model.figure_file_size = @submission.nomodel_file_size
         
#         @experiment.no_model.nomodel_file_name = @submission.nomodel_file_name
#         @experiment.no_model.nomodel_content_type = @submission.nomodel_content_type
#         @experiment.no_model.nomodel_file_size = @submission.nomodel_file_size
      end

      
     @status = @experiment.valid? ? "<font color=\"green\">COMPLETED </font>".html_safe : "<font color=\"red\">INCOMPLETE</font>".html_safe
     
     # P (protein), R (RNA), D (DNA), M (membrane), N (nanoparticle), X (complex protein RNA), Y  (complex protein DNA), Z (complex protein membrane), E (complex protein RNA DNA), F (all five), Q (protein nanoparticle)
     # H (protein nanoparticle DNA), G (nanoparticle DNA)

     if @experiment.valid?
       if @experiment.protein && !(@experiment.rna) && !(@experiment.dna) && !(@experiment.membrane) && !(@experiment.nanoparticle) 
         @code_termini = "P"
       elsif @experiment.rna && !(@experiment.protein) && !(@experiment.dna) && !(@experiment.membrane) && !(@experiment.nanoparticle) 
         @code_termini = "R" 
       elsif @experiment.dna && !(@experiment.rna) && !(@experiment.protein) && !(@experiment.membrane) && !(@experiment.nanoparticle)              
         @code_termini = "D" 
       elsif @experiment.membrane && !(@experiment.rna) && !(@experiment.dna) && !(@experiment.protein) && !(@experiment.nanoparticle)              
         @code_termini = "M" 
       elsif @experiment.nanoparticle && !(@experiment.rna) && !(@experiment.dna) && !(@experiment.membrane) && !(@experiment.protein)             
         @code_termini = "N" 
       elsif @experiment.rna && (@experiment.protein) && !(@experiment.dna) && !(@experiment.membrane) && !(@experiment.nanoparticle) 
         @code_termini = "X"               
       elsif @experiment.protein && !(@experiment.rna) && (@experiment.dna) && !(@experiment.membrane) && !(@experiment.nanoparticle)            
         @code_termini = "Y"
       elsif @experiment.nanoparticle && !(@experiment.rna) && !(@experiment.dna) && !(@experiment.membrane) && (@experiment.protein)             
         @code_termini = "Q"       
       elsif @experiment.nanoparticle && !(@experiment.rna) && (@experiment.dna) && !(@experiment.membrane) && (@experiment.protein)             
         @code_termini = "H"
       elsif @experiment.nanoparticle && !(@experiment.rna) && (@experiment.dna) && !(@experiment.membrane) && !(@experiment.protein)             
         @code_termini = "G"
       else
         @code_termini = "U" # Not other wise specified
       end
     end   

     authorize! :edit, @submission
            
     respond_to do |format|
          format.html 
          format.xml  { render :xml => @submission, :status => :created, :location => @submission }
     end     
   end
   
   
   def destroy_submission # remove submission from database and file system
     authorize! :manage, @submission    
     @submission = Submission.find_by_id(params[:id])  
     directory = Rails.root.join("public", "SAX_DATA", @submission.data_directory)     
     sub_directories = Array.new
     if Dir.exists?(directory)
       Dir.foreach(directory) {|string|
         if File.directory?("#{directory}/#{string}") && string =~ /^[^.]/     
           sub_directories << directory +"/"+string
         end       
       }
     end     
     puts sub_directories
     if Submission.destroy(params[:id])  
       #
       # Go through each subdirectory and empty contents
       #
       sub_directories.each do |sub|
         if Dir.exists?(sub)
           files = Dir.entries(sub).select{|v| v =~ /^[^.]/ || v =~ /^.[a-zA-Z]/}
           files.each do |file|
             if File.exists?("#{sub}/#{file}")
               File.delete("#{sub}/#{file}")
             end
           end
           Dir.rmdir(sub)
         end
       end
       #
       # remove submission directory
       #
       if Dir.exists?(directory)
         files = Dir.entries(directory).select{|v| v =~ /^[^.]/ || v =~ /^.[a-zA-Z]/}
         files.each do |file|
           if File.exists?("#{directory}/#{file}") && !File.directory?("#{directory}/#{file}")
             File.delete("#{directory}/#{file}")
           end
         end
         Dir.rmdir(directory)
         if !Dir.exists?(directory)
           flash[:notice] = "Directory Removed"
         end
       end
       redirect_to :action =>'active'
     else
       flash[:notice] = "Something went wrong, deletion averted!"
       render :action => "active" 
     end
   end
   #
   # Access to edit the new, status true means editable
   #
   def edit_basic_information
     #
     # Open summary.txt if it exists and read in information
     #

     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])

     data_file = Rails.root.join("public", "SAX_DATA",params[:id], "summary.txt")     
     if File.exists? data_file
       #
       # Open summary.txt and read in for filling in form
       #
       data_lines = Array.new
       open(data_file){|f| data_lines = f.readlines}
       @experiment = build_experiment(data_lines, @submission.data_directory)         
       @experiment.email = @submission.email       
     end
     authorize! :manage, @submission
     respond_to do |format|
          format.html 
          format.xml  { render :xml => @submission, :status => :created, :location => @submission }
     end          
   end

   def edit_experimental_details
     #
     # Open summary.txt if it exists and read in information
     #
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     data_file = Rails.root.join("public", "SAX_DATA",params[:id], "summary.txt")          

     if File.exists? data_file
       #
       # Open summary.txt and read in for filling in form
       #
       data_lines = Array.new
       open(data_file){|f| data_lines = f.readlines}
       @experiment = build_experiment(data_lines, @submission.data_directory)
       #         
     end
      @salt = { 
       "none" => "none",
       "NaCl" => "NaCl",
       "KCl" => "KCl",
       "NaBr" => "NaBr",
       "KBr" => "KBr",
       "RbCl" => "RbCl",
       "CsCl" => "CsCl",
       "LiCl" => "LiCl",
       "TlCl" => "TlCl",
       "NaAcetate" => "NaAcetate",
       "KAcetate" => "KAcetate",            
       "TlAcetate" => "TlAcetate"    
       }
       @divalent = {"none" => "none","MgCl2" => "MgCl2","MnCl2" => "MnCl2","CaCl2" => "CaCl2", "ZnCl2" => "ZnCl2"}
     authorize! :manage, @submission
     respond_to do |format|
          format.html 
          format.xml  { render :xml => @submission, :status => :created, :location => @submission }
     end        
  end           
           
           
  def edit_saxs_parameters
    #
    # Open summary.txt if it exists and read in information
    #
    @experiment = Experiment.new
    @submission = Submission.find_by_data_directory(params[:id])
    data_file = Rails.root.join("public", "SAX_DATA", params[:id], "summary.txt")         

    if File.exists? data_file
      #
      # Open summary.txt and read in for filling in form
      #
      # Have to return object with information in existing form
      #
      data_lines = Array.new
      open(data_file){|f| data_lines = f.readlines}
      @experiment = build_experiment(data_lines, @submission.data_directory)
      #
      # Parse through the file and make the Experiment object
      #         
    end
     authorize! :manage, @submission
    respond_to do |format|
          format.html 
          format.xml  { render :xml => @submission, :status => :created, :location => @submission }
    end
  end           
                    
                 
  def edit_authors
    #
    # Open summary.txt if it exists and read in information
    #
    @author = Author.new
    @experiment = Experiment.new
    @submission = Submission.find_by_data_directory(params[:id])
    data_file = Rails.root.join("public", "SAX_DATA",params[:id], "summary.txt")         

    if File.exists? data_file
      #
      # Open summary.txt and read in for filling in form
      #
      data_lines = Array.new
      open(data_file){|f| data_lines = f.readlines}
      @experiment = build_experiment(data_lines, @submission.data_directory)      
      #
      # if File does not exist, then just render the form
      #                 
    end
     authorize! :manage, @submission    
    respond_to do |format|
          format.html 
          format.xml  { render :xml => @submission, :status => :created, :location => @submission }
    end
  end  
  
  def add_author
    @submission = Submission.find_by_data_directory(params[:id])
    @author = Author.new(params[:author])
    @author.remove_dots_change_case
    data_file = Rails.root.join("public", "SAX_DATA", params[:id], "summary.txt")         
    file_lines = Array.new

    if File.exists?(data_file) && @author.valid?
      #
      # read in existing summary file and build experiment model
      #        
      open(data_file){|f| file_lines = f.readlines}
      @experiment = build_experiment(file_lines, @submission.data_directory)
      #
      # update prior_info with new_info 
      #
      @experiment.authors.build(:lastname => @author.lastname, :initials => @author.initials)
      #
      # Write experiment to summary.txt
      #
      write_experiment(@experiment, @submission.data_directory)
      
    elsif @author.valid?
      @experiment = Experiment.new(params[:experiment])
      @experiment.created_at = DateTime.now # Summary.txt creation date, different from database approval or alteration date
      @experiment.ip_address = request.remote_ip
      @experiment.email = @submission.email
      #
      # Create new summary file and write out array elements
      #
      @experiment.authors.build(:lastname => @author.lastname, :initials => @author.initials)
      write_experiment(@experiment, @submission.data_directory)
    end
     authorize! :manage, @submission
    respond_to do |format|
      format.html {redirect_to edit_authors_path(@submission.data_directory) }     
    end
  end
  
  def remove_author
       #
       # Match by lastname and initials
       #
       @submission = Submission.find_by_data_directory(params[:id])
       authorize! :manage, @submission     
       data_file = Rails.root.join("public", "SAX_DATA",params[:id], "summary.txt")                 
       if File.exists? data_file
         #
         # Open summary.txt and read in for filling in form
         #
         data_lines = Array.new
         open(data_file){|f| data_lines = f.readlines}
         @experiment = build_experiment(data_lines, @submission.data_directory) 
         #
         # At this point, authors is associated with experiment, clear all authors
         #
         @experiment.authors.clear     
         #
         # Parse through the file and remake the Author association using condition
         #         
         data_lines.each do |line|           
           case           
              when line.match(/^AUTHOR/)    
               # Can have multiple authors, build association with each encounter in the summary.txt file
               #
               nameline = line.split(/[\t]+/)
               if !(nameline[1] == params[:author_lastname]) && !(nameline[2] == params[:author_initials])
                   @experiment.authors.build(:lastname => nameline[1], :initials => nameline[2])           
               end
           end       
         end
         #
         # Write new summary file and then render edit_authors agains
         #
         # Create new summary file and write out array elements
         #
         write_experiment(@experiment, @submission.data_directory)                          
       end
              
    respond_to do |format|       
       format.html {redirect_to edit_authors_path(@submission.data_directory) }        
    end   
  end
   #
   # Saves for editing later and resends an email with link
   #
   def save

     @submission = Submission.find_by_data_directory(params[:experiment][:data_directory])   
     authorize! :manage, @submission       
     #
     # Open summary.txt file and write out new contents
     #
     # Read in, if file exists
     #
     file_lines = Array.new
     data_file = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "summary.txt")          
#     data_file = "#{::Rails.root.to_s}/public/SAX_DATA/#{@submission.data_directory}/summary.txt"
     if File.exists? data_file
       #
       # read in existing summary file and build experiment model
       #        
       open(data_file){|f| file_lines = f.readlines}
       @experiment = build_experiment(file_lines, @submission.data_directory)
       #
       # update prior_info with new_info 
       #  
       params[:experiment].each do |key|
          @experiment[key[0]] = key[1]          
       end
       #
       # Write experiment to summary.txt
       #
       write_experiment(@experiment, @submission.data_directory)
       
     else
       @experiment = Experiment.new(params[:experiment])
       @experiment.created_at = DateTime.now # Summary.txt creation date, different from database approval or alteration date
       @experiment.ip_address = request.remote_ip
       @experiment.email = @submission.email
       #
       # Create new summary file and write out array elements
       #
       # Write_experiment(@experiment)
       write_experiment(@experiment, @submission.data_directory)
     end
     
     respond_to do |format|
          format.html {redirect_to deposition_path(@submission.data_directory) } 
          format.xml  { render :xml => @submission, :status => :created, :location => @submission }
     end
          
   end
   #

   #
   def create
    #
    @submission = Submission.new(params[:submission])
    #
    # add current_user id to @submission, must be logged in 
    #
    @submission.user_id = current_user.id
    #
    # Create data directory
    #
    @submission.data_directory = Time.now.to_i.to_s    
    directory = Rails.root.join("public", "SAX_DATA", @submission.data_directory)              
    @submission.editing_count = 1
    Dir.mkdir(directory)
    #
    # Write out blank Summary file
    # 
    respond_to do |format|
       if @submission.save && (File.directory? directory)
         #
         # Send email link
         #
         Notifier.registration(@submission).deliver

         format.html { redirect_to(@submission, :notice => 'Submission registration was successful. Please check your email account!') }
         format.xml  { render :xml => @submission, :status => :created, :location => @submission }
       else
         format.html { render :action => "new" }
         format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
       end
    end
   end

   def edit_data_files

     #
     # Open summary.txt if it exists and read in information
     #
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])

     authorize! :manage, @submission     
     file_lines = Array.new
     data_file = Rails.root.join("public", "SAX_DATA", params[:id], "summary.txt")               

     if File.exists? data_file
       #
       # Open summary.txt and read in for filling in form
       #
       data_lines = Array.new
       open(data_file){|f| data_lines = f.readlines}
       @experiment = build_experiment(data_lines, @submission.data_directory)      
       #
       # Parse through the file and make the Experiment object
       #
       if !@experiment.iofq_file_name.nil?         
         @size = @experiment.iofq_file_name.split(/,\s/).size                                         
       end
     end  

     respond_to do |format|
           format.html 
           format.xml  { render :xml => @submission, :status => :created, :location => @submission }
     end
   end

   def add_iofq_file
     #
     # Add file, plot and give user the ability to add another and plot, such as multiple concentrations
     #
     @submission = Submission.find_by_data_directory(params[:data_directory])
     authorize! :manage, @submission   
     original_subdirectory = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "originals")               
     experiment_directory = Rails.root.join("public", "SAX_DATA", @submission.data_directory) 
     @iofqState = false           
     @iofq_data=[]
     @qmax =0.0
     @kratky_data=[]                  
     #
     # Check if originals exists
     #
     iofq_file = experiment_directory.join("iofq_data_file.dat")
     if File.exists?(iofq_file)
       # Private method at bottom loadFileIntoJSON()
       @iofq_data, @qmax = loadFileIntoJSON(iofq_file, true)
       #create Kratky data
       @kratky_data = createKratky(iofq_file, @qmax)       
       @iofqState = true
     end

     if File.directory?(original_subdirectory) 
       #
       # load *.dat files
       #       
       @files = Dir.glob("#{original_subdirectory}/*.int")
     end
     
     respond_to do |format|
       format.html # new.html.erb
     end
   end      

   def upload_iofq_file
     #
     # Add file, plot and give user the ability to add another dataset, i.e., as multiple concentrations
     #
     @submission = Submission.find_by_data_directory(params[:id])
     @iofqState = false
     @iofq_data=[]
     @qmax =0.0
     @kratky_data=[]
     
     original_subdirectory = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "originals")
     experiment_directory = Rails.root.join("public", "SAX_DATA", @submission.data_directory)
     authorize! :manage, @submission        
     @files = Array.new
     if File.directory?(original_subdirectory) 
       #
       # load *.dat files, this is required when starting the method and nothing is being uploaded, an empty load
       #       
       @files = Dir.glob("#{original_subdirectory}/*.int")
     end

     if Submission.presence_of?(:datafile, params[:submission])
       @submission.datafile = params[:submission][:datafile] # non-Database model attribute (datafile)
       
       iofq_file = params[:submission][:datafile]

       data_lines = Array.new
       open(iofq_file.tempfile.path){|f| data_lines = f.readlines }      
       
       @submission.data_lines = data_lines # non-Database model attribute (data_lines)
       
       if @submission.valid?
          Submission.uploadINT(experiment_directory, original_subdirectory, iofq_file, "iofq_data_file", params[:isnm])
          #
          # Add file to summary.txt
          # 
          @files = Dir.glob("#{original_subdirectory}/*.int")   
          make_iofq_filename(@submission) # called from iofq_filename module 
          
          iofq_file = experiment_directory.join("iofq_data_file.dat")          
          # Method in ApplicationController
          @iofq_data, @qmax = loadFileIntoJSON(iofq_file, true)
          #create Kratky data
          @kratky_data = createKratky(iofq_file, @qmax)                    
          @iofqState = true          
       end
       
     end
     
     respond_to do |format|
         format.html { render :controller => 'deposition', :action => 'add_iofq_file', :id => @submission.data_directory } # 
     end
   end      

   def remove_file
     
     @submission = Submission.find_by_data_directory(params[:id])    
     authorize! :manage, @submission        
     file = Rails.root.join("public", "SAX_DATA", params[:file])
     directory = Rails.root.join("public", "SAX_DATA", params[:id])
     @iofq_data =[]
     @kratky_data =[]
     @qmax =0.0

     #
     # Check User ID against current user before deleting
     #
     if File.exists?(file)
        File.delete(file)
        
        tempFile = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "med_res_IofQ.png")
        if File.exists?(tempFile)
           File.delete(Rails.root.join("public", "SAX_DATA", @submission.data_directory, "med_res_IofQ.png"))          
        end
        # add small file as well
        #
        # Delete iofq_data_file and remake using *.dat.int in originals directory 
        # 
        iofqfile = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "iofq_data_file.dat")

        File.delete(iofqfile)
        #
        # Grab existing *.dat.int files and remake composite iofq_data_file
        #
        selected = Array.new
        
        files = Dir.glob(Rails.root.join("public", "SAX_DATA", @submission.data_directory, "originals", "*.int"))

        make_iofq_filename(@submission) # called from iofq_filename module 

        if files.size > 0 # remaining files are in the originals directory
          files.each do |file|
             data_lines = Array.new
             open(file) {|f| data_lines = f.readlines }         
             selected << "\n# Following corresponds to: #{file.split(/originals\//)[1]}\n\n"         
             data_lines.each do |f|
               if f =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/ && !(f =~ /[a-z=]+/)
                 if f.strip.split(/[\s\t]+/)[1].to_f > 0
                    selected << f 
                 end         
               end         
             end
          end

          open(iofqfile, 'w') do |f|
            selected.each {|i| f << i }
          end
          #
          # Make the Gnuplot the data
          #
          @iofq_data, @qmax = loadFileIntoJSON(iofqfile, true)
          #create Kratky data
          @kratky_data = createKratky(iofqfile, @qmax)       
          @iofqState = true
                    
          data_lines = Array.new
          x_array = Array.new
          y_array = Array.new
          gnuplot_lines = Array.new

          # data_lines is an array where each line contains both the x and y data as a string

          open(iofqfile) {|f| data_lines = f.readlines }
          
          data_lines.each do |x| 
           if x =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/ 
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
          outpath = File.join("#{Rails.root}/public/SAX_DATA/#{@submission.data_directory}", 'med_res_IofQ.png')        
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
         # gnuplot_lines << "plot '#{iofqfile}' using 1:2 notitle with points pointtype 7 ps 0.5\n"
          gnuplot_lines << "plot '#{iofqfile}' using 1:2:(column(-2)) notitle with points pointtype 7 ps 0.5 lc variable \n"        
          gnupath = File.join("#{Rails.root}/public/SAX_DATA/#{@submission.data_directory}", 'med_res_IofQ.plt')        
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
          gnuplot_lines << "set ytics auto nomirror\n"
          gnuplot_lines << "set xtics 0, #{(tic*10**1).round.to_f/10} nomirror\n"
          gnuplot_lines << "set xlabel \"q\" font \"times, 14\" tc rgb '#494949' \n"
          gnuplot_lines << "set ylabel \"I(q) * q^2\" font \"times, 14\" tc rgb '#494949' \n"
          gnuplot_lines << "set border 3\n"
          gnuplot_lines << "plot '#{iofqfile}' using 1:($1*$1*$2):(column(-2)) notitle with points pointtype 3 pointsize 0.4 lc variable\n"

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
          gnuplot_lines << "set logscale y\n"
          gnuplot_lines << "unset ytics \n"
          gnuplot_lines << "unset xtics \n"
          gnuplot_lines << "set border 3\n"
          gnuplot_lines << "plot '#{iofqfile}' using 1:2:(column(-2)) notitle with points pointtype 7 ps 0.5 lc variable \n"    
          open(gnupath, 'w') do |f|
             gnuplot_lines.each {|i| f << i }
          end
          command_code = "gnuplot #{gnupath}"
          system(command_code)
          File.delete(gnupath)
                          
       end
     end
     #
     # after deleting must remake iofq_data_file
     # 
     original_subdirectory = Rails.root.join("public", "SAX_DATA", params[:id], "originals")

     #
     # Check if originals exists
     #
     @files = Array.new
     if File.directory?(original_subdirectory) 
       #
       # load *.dat files
       #       
       @files = Dir.glob("#{original_subdirectory}/*.dat.int")
     end

     respond_to do |format|
       format.html { render :controller => 'deposition', :action => 'add_iofq_file', :id => @submission.data_directory }
       format.xml  { render :xml => @submission }
     end     
   end
   
   def add_pofr_file
     #
     # User is allowed to only upload one file (can be gnom or generic three column file)
     #
     @submission = Submission.find_by_data_directory(params[:data_directory])
     authorize! :manage, @submission
     @pofr_imagefile = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "med_res_PofR.png")
     original_subdirectory = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "originals")
     experiment_directory = Rails.root.join("public", "SAX_DATA", @submission.data_directory)
     @pofr_data =[]
     @rmax = 0.0
     @pofrState = false
     #
     # Check if originals exists
     #
     
     if File.directory?(original_subdirectory) 
       #
       # load *.pofr files
       #       
       @files = Dir.glob("#{original_subdirectory}/*.pofr")
       
       pofr_file = experiment_directory.join("pofr_data_file.dat") 
       if File.exists?(pofr_file)         
         # Method in ApplicationController
         @pofr_data, @rmax = loadFileIntoJSON(pofr_file, false)
         @pofrState = true           
       end
     end
          
     
     respond_to do |format|
       format.html # new.html.erb
       format.xml  { render :xml => @submission }
     end
   end      

   def upload_pofr_file
     #
     # No removal of prior, just over-write?
     #
     # Check if prior image file, if so, this means we have a pofr_data_file present
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:data_directory])
     authorize! :manage, @submission
     
     original_subdirectory = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "originals")
     experiment_directory = Rails.root.join("public", "SAX_DATA", @submission.data_directory)
     data_file = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "summary.txt")     
     @rmax=0.0
     @pofr_data =[]       
     @pofrState = false
     
     if File.exists? data_file
       #
       # Open summary.txt and read in for filling in form
       #
       data_lines = Array.new
       open(data_file){|f| data_lines = f.readlines}             
       @experiment = build_experiment(data_lines, @submission.data_directory)      
     end     
     #
     # Remove Prior Files if they exists
     #
     if !(@experiment.pofr_file_name.nil?) && File.exists?(Rails.root.join("public", "SAX_DATA", @submission.data_directory, "originals", @experiment.pofr_file_name)) 
       File.delete(Rails.root.join("public", "SAX_DATA", @submission.data_directory, "originals", @experiment.pofr_file_name))
     end
     
     med_res_PNG = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "med_res_PofR.png")
     if File.exists?("#{Rails.root}/public/SAX_DATA/#{@submission.data_directory}/med_res_PofR.png") && !(@experiment.pofr_file_name.nil?)
       File.delete(med_res_PNG)
     end  
     #
     # Upload new file and make new *.png file
     #   
     if Submission.presence_of?(:datafile, params[:submission])
       @submission.datafile = params[:submission][:datafile] # non-Database model attribute (datafile)       
       pofr_file = params[:submission][:datafile]
       data_lines = Array.new
       open(pofr_file.tempfile.path){|f| data_lines = f.readlines }
       @submission.data_lines = data_lines # non-Database model attribute (data_lines)         
       @pofr_imagefile = med_res_PNG
       
       if @submission.valid?
          upload_POFR(experiment_directory, original_subdirectory, pofr_file, "pofr_data_file")       
          #
          # Add file to summary.txt
          # 
          @files = Dir.glob("#{original_subdirectory}/*.pofr")   
          @experiment.pofr_file_name = @files[0].split(/originals\//)[1]
          #
          # Make new summary file
          #
          write_experiment(@experiment, @submission.data_directory)                
          @pofrState = true  
          pofr_file = experiment_directory.join("pofr_data_file.dat")            
          @pofr_data, @rmax = loadFileIntoJSON(pofr_file, false)
       end       
     end

     respond_to do |format|
         format.html { render :controller => 'deposition', :action => 'add_pofr_file', :id => @submission.data_directory }# new.html.erb
     end
   end
   
   def add_gene
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission        
     @gene = Expgene.new(params[:expgene])

     if !@gene.experimental_sequence.empty?
        @gene.exp_mw = calculate_mw(@gene.experimental_sequence.chomp.gsub(/[\r\n\t\s]+/,""))
        puts @gene.experimental_sequence.chomp.gsub(/[\r\n\t\s]+/,"")
     end
     data_file = Rails.root.join("public", "SAX_DATA", params[:id], "summary.txt")             
     file_lines = Array.new
     if File.exists?(data_file) && @gene.valid?
       #
       # read in existing summary file and build experiment model
       #        
       open(data_file){|f| file_lines = f.readlines}
       @experiment = build_experiment(file_lines, @submission.data_directory)
       #
       # update prior_info with new_info 
       #
       @experiment.expgenes.build(:exp_mw =>@gene.exp_mw, :experimental_sequence => @gene.experimental_sequence.chomp.gsub(/[\s\r\n\t]+/,""), :annotation => @gene.annotation.chomp.gsub(/[\s\r\n\t]+/,"\s"), :abbr_name => @gene.abbr_name)
       #
       # Write experiment to summary.txt
       #
       write_experiment(@experiment, @submission.data_directory)
       redirect_to edit_genes_path(@submission.data_directory) and return if @gene.valid?
     elsif @gene.valid?
       @experiment = Experiment.new(params[:experiment])
       @experiment.created_at = DateTime.now # Summary.txt creation date, different from database approval or alteration date
       @experiment.ip_address = request.remote_ip
       @experiment.email = @submission.email
       #
       # Create new summary file and write out array elements
       #
       @experiment.expgenes.build(:exp_mw =>@gene.exp_mw, :experimental_sequence => @gene.experimental_sequence.chomp.gsub(/[\s\r\n\t]+/,""), :annotation => @gene.annotation.chomp.gsub(/[\s\r\n\t]+/,"\s"), :abbr_name => @gene.abbr_name)
       write_experiment(@experiment, @submission.data_directory)
       redirect_to edit_genes_path(@submission.data_directory) and return if @gene.valid?       
     end
     
     open(data_file){|f| file_lines = f.readlines}
     @experiment = build_experiment(file_lines, @submission.data_directory)
     
     respond_to do |format|
         format.html { render :controller => 'submission', :action => 'edit_genes', :id => @submission.data_directory}                
     end
     
   end
   
   def edit_genes
     #
     # Open summary.txt if it exists and read in information
     #
     @gene = Expgene.new
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission
     data_file = Rails.root.join("public", "SAX_DATA", params[:id], "summary.txt")        
     if File.exists? data_file
       #
       # Open summary.txt and read in for filling in form
       #
       data_lines = Array.new
       open(data_file){|f| data_lines = f.readlines}
       @experiment = build_experiment(data_lines, @submission.data_directory)      
       #
       # if File does not exist, then just render the form
       #                 
     end
     respond_to do |format|
           format.html 
     end
   end
   
   def remove_gene
        #
        # Match by lastname and initials
        #
        @submission = Submission.find_by_data_directory(params[:id])
        authorize! :manage, @submission           
        data_file = Rails.root.join("public", "SAX_DATA", params[:id], "summary.txt")          
        if File.exists? data_file
          #
          # Open summary.txt and read in for filling in form
          #
          data_lines = Array.new
          open(data_file){|f| data_lines = f.readlines}
          @experiment = build_experiment(data_lines, @submission.data_directory) 
          #
          # At this point, authors is associated with experiment, clear all authors
          #
          @experiment.expgenes.each do |gene|
            if gene.gene_count == params[:delete_me]
               @experiment.expgenes.delete(@experiment.expgenes[gene.gene_count.to_i - 1])                        
            end
          end
          #
          # Write new summary file and then render edit_authors agains
          #
          # Create new summary file and write out array elements
          #
          write_experiment(@experiment, @submission.data_directory)                          
        end       
     respond_to do |format|       
        format.html {redirect_to edit_genes_path(@submission.data_directory) }        
     end     
   end
   
   
   def add_models
     #
     # Open summary.txt if it exists and read in information
     #
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission        
     data_file = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "summary.txt")        
     @fit_image = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "med_res_FIT.png")        
     @ensemble_fit_image = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "med_res_ensemble_FIT.png")        
     @nomodel_image = String.new
     noModelDir = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "nomodel")
     if Dir.exists?(noModelDir)
       files = Dir.entries(noModelDir).select{|v| v =~ /\.(png|jpg|tiff)/}
       @nomodel_image = files.size == 1 ? noModelDir.join(files[0]) : nil       
     end
     
     if File.exists? data_file
       #
       # Open summary.txt and read in for filling in form
       #
       # Have to return object with information in existing form
       #
       data_lines = Array.new
       open(data_file){|f| data_lines = f.readlines}
       @experiment = build_experiment(data_lines, @submission.data_directory)
       #
       # Parse through the file and make the Experiment object
       #
       if !@experiment.ensemble.nil?
         @experiment.ensemble.diagnostic_file_name = @submission.diagnostic_file_name
         @experiment.ensemble.diagnostic_content_type = @submission.diagnostic_content_type
         @experiment.ensemble.diagnostic_file_size = @submission.diagnostic_file_size                  
       end         
     end
     respond_to do |format|
       format.html # add_models.html.erb
       format.xml  { render :xml => @submission }
     end
   end
   
   def add_dammin_model
     @submission = Submission.find_by_data_directory(params[:id])   
     authorize! :manage, @submission          
     #
     # Check summary file for prior model
     #
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")
     if File.exists? data_file
        # open file and make new object    
        data_lines = Array.new
        open(data_file){|f| data_lines = f.readlines}
        @experiment = build_experiment(data_lines, @submission.data_directory)
        if @experiment.dammin_result.nil?
           @dammin = @experiment.build_dammin_result
        else
           @dammin = @experiment.dammin_result      
        end
     else
        @experiment = Experiment.new(:data_directory => params[:id])
        @experiment.build_dammin_result
        @dammin = DamminResult.new        
     end     
     
     respond_to do |format|
       format.html # add_dammin_model.html.erb
       format.xml  { render :xml => @submission }
     end     
   end
   
   def save_dammin
     #
     # validate the dammin model and create association with Experiment and write to summary file.  
     #
     @dammin = DamminResult.new(params[:dammin_result])
     #
     # if single, average and superposition models are empty, this will reset prior information
     #
     @dammin.data_directory = params[:id]
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission        
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")  
     dammin_subdirectory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "dammin")  
     experiment_directory = Rails.root.join("public","SAX_DATA",@submission.data_directory)               
     if !(File.directory? dammin_subdirectory)
       Dir.mkdir(dammin_subdirectory)
     end
                
     if @dammin.single_model_filename.tempfile.kind_of?(StringIO) or @dammin.single_model_filename.tempfile.kind_of?(Tempfile)

       # pofr_file.tempfile.path 
       #if not empty, this implies a file is ready to be uploaded so, we will upload, copy, parse and rename the file in the model
       uploadFile(experiment_directory, dammin_subdirectory, @dammin.single_model_filename, "single_dammin_model.pdb")
       @dammin.single_model_filename = @dammin.single_model_filename.original_filename
     end

     if @dammin.average_model_filename.tempfile.kind_of?(StringIO) or @dammin.average_model_filename.tempfile.kind_of?(Tempfile)
       #if not empty, this implies a file is ready to be uploaded so, we will upload, copy, parse and rename the file in the model
       uploadFile(experiment_directory, dammin_subdirectory, @dammin.average_model_filename, "average_dammin_model.pdb") 
       @dammin.average_model_filename = @dammin.average_model_filename.original_filename
     end

     if !@dammin.subcomb_model.nil? and (@dammin.subcomb_model.tempfile.kind_of?(StringIO) or @dammin.subcomb_model.tempfile.kind_of?(Tempfile))
       #if not empty, this implies a file is ready to be uploaded so, we will upload, copy, parse and rename the file in the model
       uploadFile(experiment_directory, dammin_subdirectory, @dammin.subcomb_model, "hires_dammin_model.pdb")   
       @dammin.subcomb_model = @dammin.subcomb_model.original_filename
     end                
          
     if @dammin.valid?
       if File.exists? data_file
         #
         # Open summary.txt and read in for filling in form
         #
         data_lines = Array.new
         open(data_file){|f| data_lines = f.readlines}
         @experiment = build_experiment(data_lines, @submission.data_directory)
         @experiment.build_dammin_result         
         @experiment.dammin_result = @dammin  
         write_experiment(@experiment, @submission.data_directory)
         redirect_to add_models_path(@submission.data_directory) and return if @dammin.valid?
       end              
     end
     respond_to do |format|
         format.html { render :controller => 'submission', :action => 'add_dammin_model', :id => params[:id] }
         format.xml  { render :xml => @submission }
     end     
   end
   
   def destroy_dammin_model
     #
     # remove from summary.txt file and delete directory and associated files summary.txt file.  
     # write new summary.txt file
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission        
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")  
     experiment_dir = Rails.root.join("public","SAX_DATA",@submission.data_directory)      
     dammin_dir = Rails.root.join("public","SAX_DATA",@submission.data_directory, "dammin")       
     data_lines = Array.new
     # Open summary file
     open(data_file){|f| data_lines = f.readlines}
     # make Experiment
     @experiment = build_experiment(data_lines, @submission.data_directory) 
     #
     # Delete files and remove directory
     #

     File.delete(dammin_dir.join(@experiment.dammin_result.single_model_filename)) if File.exists?(dammin_dir.join(@experiment.dammin_result.single_model_filename))
     File.delete(dammin_dir.join(@experiment.dammin_result.average_model_filename)) if File.exists?(dammin_dir.join(@experiment.dammin_result.average_model_filename))
     File.delete(dammin_dir.join(@experiment.dammin_result.subcomb_model)) if (!@experiment.dammin_result.subcomb_model.nil? && File.exists?(dammin_dir.join(@experiment.dammin_result.subcomb_model)) )
     
     File.delete(experiment_dir.join("single_dammin_model.pdb")) if File.exists?(experiment_dir.join("single_dammin_model.pdb"))
     File.delete(experiment_dir.join("average_dammin_model.pdb")) if File.exists?(experiment_dir.join("average_dammin_model.pdb"))
     File.delete(experiment_dir.join("hires_dammin_model.pdb")) if File.exists?(experiment_dir.join("hires_dammin_model.pdb"))

     Dir.rmdir(dammin_dir)
     # reset dammin_result
     @experiment.dammin_result = nil     
     write_experiment(@experiment, @submission.data_directory)     
     redirect_to add_models_path(params[:id])
   end
   
   def add_gasbor_model
     @submission = Submission.find_by_data_directory(params[:id])     
     authorize! :manage, @submission        
     #
     # Check summary file for prior model
     #
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")       
     if File.exists? data_file
        # open file and make new object    
        data_lines = Array.new
        open(data_file){|f| data_lines = f.readlines}
        @experiment = build_experiment(data_lines, @submission.data_directory)
        @gasbor = GasborResult.new
        
     else
        @experiment = Experiment.new(:data_directory => params[:id])
        @gasbor = GasborResult.new        
     end     
     
     respond_to do |format|
       format.html # add_dammin_model.html.erb
       format.xml  { render :xml => @submission }
     end
   end
   
   def save_gasbor
     #
     # validate the dammin model and create association with Experiment and write to summary file.  
     #
     @gasbor = GasborResult.new(params[:gasbor_result])
     #
     # if single, average and superposition models are empty, this will reset prior information
     #
     @gasbor.data_directory = params[:id]
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission        
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")         
     gasbor_subdirectory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "gasbor")              
     experiment_directory =  Rails.root.join("public","SAX_DATA",@submission.data_directory)              
     if !(File.directory? gasbor_subdirectory)
       Dir.mkdir(gasbor_subdirectory)
     end
                
     if @gasbor.single_model_filename.tempfile.kind_of?(StringIO) or @gasbor.single_model_filename.tempfile.kind_of?(Tempfile)
       #if not empty, this implies a file is ready to be uploaded so, we will upload, copy, parse and rename the file in the model
       uploadFile(experiment_directory, gasbor_subdirectory, @gasbor.single_model_filename, "single_gasbor_model.pdb")
       @gasbor.single_model_filename = @gasbor.single_model_filename.original_filename
     end

     if @gasbor.average_model_filename.tempfile.kind_of?(StringIO) or @gasbor.average_model_filename.tempfile.kind_of?(Tempfile)
       #if not empty, this implies a file is ready to be uploaded so, we will upload, copy, parse and rename the file in the model
       uploadFile(experiment_directory, gasbor_subdirectory, @gasbor.average_model_filename, "average_gasbor_model.pdb") 
       @gasbor.average_model_filename = @gasbor.average_model_filename.original_filename
     end

     if !@gasbor.subcomb_model.nil? and (@gasbor.subcomb_model.tempfile.kind_of?(StringIO) or @gasbor.subcomb_model.tempfile.kind_of?(Tempfile))
       #if not empty, this implies a file is ready to be uploaded so, we will upload, copy, parse and rename the file in the model
       uploadFile(experiment_directory, gasbor_subdirectory, @gasbor.subcomb_model, "hires_gasbor_model.pdb")   
       @gasbor.subcomb_model = @gasbor.subcomb_model.original_filename
     end                
          
     if @gasbor.valid?
       if File.exists? data_file
         #
         # Open summary.txt and read in for filling in form
         #
         data_lines = Array.new
         open(data_file){|f| data_lines = f.readlines}
         @experiment = build_experiment(data_lines, @submission.data_directory)
         @experiment.gasbor_results.build()     
         @experiment.gasbor_results[0] = @gasbor
         #
         write_experiment(@experiment, @submission.data_directory)
         redirect_to add_models_path(@submission.data_directory) and return if @gasbor.valid?
       end              
     end
     respond_to do |format|
         format.html { render :controller => 'submission', :action => 'add_gasbor_model', :id => params[:id] }
         format.xml  { render :xml => @submission }
     end     
   end
   
   def destroy_gasbor_model
     #
     # remove from summary.txt file and delete directory and associated files summary.txt file.  
     # write new summary.txt file
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission  
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")         
     gasbor_subdirectory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "gasbor")              
     experiment_directory =  Rails.root.join("public","SAX_DATA",@submission.data_directory)              
           
     data_lines = Array.new
     # Open summary file
     open(data_file){|f| data_lines = f.readlines}
     # make Experiment
     @experiment = build_experiment(data_lines, @submission.data_directory) 
     #
     # Delete files and remove directory
     #
     files = Dir.entries(gasbor_subdirectory).select{|v| v =~ /^[^.]/}
     files.each do |file|
       File.delete("#{gasbor_subdirectory}/#{file}")
     end
     Dir.rmdir(gasbor_subdirectory)
     files = Dir.entries(experiment_directory).select{|v| v =~ /gasbor/}     
     files.each do |file|
       File.delete(experiment_directory.join(file))       
     end     

     # reset gasbor_results
     @experiment.gasbor_results.clear
     write_experiment(@experiment, @submission.data_directory)     
     redirect_to add_models_path(params[:id])
   end
   
   def add_structural_model
     @submission = Submission.find_by_data_directory(params[:id])   
     authorize! :manage, @submission          
     #
     # Check summary file for prior model
     #
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")         
     
     if File.exists? data_file
        # open file and make new object    
        data_lines = Array.new
        open(data_file){|f| data_lines = f.readlines}
        @experiment = build_experiment(data_lines, @submission.data_directory)
        @structure = StructuralModel.new
     else
        @experiment = Experiment.new(:data_directory => params[:id])
        @structure = StructuralModel.new        
     end     
     
     respond_to do |format|
       format.html # add_structural_model.html.erb
       format.xml  { render :xml => @submission }
     end
   end
   
   def save_structural
     #
     # validate the dammin model and create association with Experiment and write to summary file.  
     #
     @structure = StructuralModel.new(params[:structural_model])
     @structure.data_directory = params[:id]
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission        
     fit_lines = Array.new
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")         
     structure_subdirectory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "structure")              
     experiment_directory =  Rails.root.join("public","SAX_DATA",@submission.data_directory)              
     
     if !(File.directory? structure_subdirectory)
       Dir.mkdir(structure_subdirectory)
     end
                
     if @structure.pdb_filename.tempfile.kind_of?(StringIO) or @structure.pdb_filename.tempfile.kind_of?(Tempfile)
       #if not empty, this implies a file is ready to be uploaded so, we will upload, copy, parse and rename the file in the model
       uploadFile(experiment_directory, structure_subdirectory, @structure.pdb_filename, "pdb_model.pdb")
       @structure.pdb_filename = @structure.pdb_filename.original_filename
     end
     #
     # need to do a check on fit file, 3 columns, 2nd and 3rd should contain intensities 
     #     
     fit_lines = Array.new
     if @structure.fit_filename.tempfile.kind_of?(StringIO) or @structure.fit_filename.tempfile.kind_of?(Tempfile)
       #if not empty, this implies a file is ready to be uploaded so, we will upload, copy, parse and rename the file in the model
       uploadFile(experiment_directory, structure_subdirectory, @structure.fit_filename, "fitted_SAXS_with_model.dat") 
       @structure.fit_filename = @structure.fit_filename.original_filename
       open(params[:structural_model][:fit_filename].tempfile.path){|f| fit_lines = f.readlines }
       @structure.fit_lines = fit_lines # non-Database model attribute (data_lines)
     end

             
     if @structure.valid?
       if File.exists? data_file
         #
         # Open summary.txt and read in for filling in form
         #
         data_lines = Array.new
         open(data_file){|f| data_lines = f.readlines}
         @experiment = build_experiment(data_lines, @submission.data_directory)
         @experiment.build_structural_model    
         @experiment.structural_model = @structure
         #
         # Make GnuPlot
         #
         StructuralModel.make_fit_plot(fit_lines, "#{Rails.root}/public/SAX_DATA/#{@submission.data_directory}")
         write_experiment(@experiment, @submission.data_directory)
         redirect_to add_models_path(@submission.data_directory) and return if @structure.valid?
       end              
     else
       #
       # delete any uploaded files
       #
       if !(@structure.fit_filename.nil?) && File.exists?("#{Rails.root}/public/SAX_DATA/#{@submission.data_directory}/structure/#{@structure.fit_filename}")
         File.delete("#{Rails.root}/public/SAX_DATA/#{@submission.data_directory}/structure/#{@structure.fit_filename}")
       end
       
       if !@structure.pdb_filename.nil? && File.exists?("#{Rails.root}/public/SAX_DATA/#{@submission.data_directory}/structure/#{@structure.pdb_filename}")
         File.delete("#{Rails.root}/public/SAX_DATA/#{@submission.data_directory}/structure/#{@structure.pdb_filename}")
       end
       
       respond_to do |format|
         format.html { render :controller => 'submission', :action => 'add_structural_model', :id => params[:id] }
         format.xml  { render :xml => @submission }
       end
      end     
   end   
   
   
   def destroy_structural_model
     #
     # remove from summary.txt file and delete directory and associated files summary.txt file.  
     # write new summary.txt file
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")
     structure_subdirectory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "structure")              
     experiment_directory =  Rails.root.join("public","SAX_DATA",@submission.data_directory)              
     
     data_lines = Array.new
     # Open summary file
     open(data_file){|f| data_lines = f.readlines}
     # make Experiment
     @experiment = build_experiment(data_lines, @submission.data_directory) 
     #
     # Delete files and remove directory
     #
     if Dir.exists?(structure_subdirectory)
       files = Dir.entries(structure_subdirectory).select{|v| v =~ /^[^.]/}
       files.each do |file|
         File.delete("#{structure_subdirectory}/#{file}")
       end
       Dir.rmdir(structure_subdirectory)
     end

     File.delete( experiment_directory.join("med_res_FIT.png") ) if File.exists?( experiment_directory.join("med_res_FIT.png") )
     File.delete( experiment_directory.join("fitted_SAXS_with_model.dat") ) if File.exists?( experiment_directory.join("fitted_SAXS_with_model.dat") )
     File.delete( experiment_directory.join("pdb_model.pdb") ) if File.exists?( experiment_directory.join("pdb_model.pdb") )
     
     @experiment.structural_model = nil     
     write_experiment(@experiment, @submission.data_directory)     
     redirect_to add_models_path(params[:id])
   end
   
   def add_ensemble_model
     #
     # Open file if it exists and grab names
     #
     @submission = Submission.find_by_data_directory(params[:id])  
     authorize! :manage, @submission        
     @ensemble = Ensemble.new 
     $ensemble = 0
     
     respond_to do |format|
       format.html
     end               
   end
   
   def add_pdb # for ensemble model
     #
     # Append ensemble.tmp and write uploaded file to ensemble directory
     #
     @pdb = params[:filename]
     @submission = Submission.find_by_data_directory(params[:id])  
     authorize! :manage, @submission
     ensemble_subdirectory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "ensemble")
     @pdbs = Array.new
     $ensemble += 1    
           
     respond_to do |format|
       format.html { redirect_to add_ensemble_model_path }
       format.js
     end     
   end
   
   def save_ensemble
     @submission = Submission.find_by_data_directory(params[:id])  
     authorize! :manage, @submission        
     @ensemble = Ensemble.new(params[:ensemble])
     experiment_directory = Rails.root.join("public","SAX_DATA",@submission.data_directory)          
     originals_directory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "originals")          
     ensemble_subdirectory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "ensemble")
     
     Dir.mkdir(ensemble_subdirectory) if !(Dir.exists?(ensemble_subdirectory))
     #
     # need to do a check on fit file, 3 columns, 2nd and 3rd should contain intensities 
     #     
     fit_lines = Array.new 
     if params[:ensemble][:fit_filename].tempfile.kind_of?(StringIO) or params[:ensemble][:fit_filename].tempfile.kind_of?(Tempfile)       
       #if not empty, this implies a file is ready to be uploaded so, we will upload, copy, parse and rename the file in the model
       uploadFile(ensemble_subdirectory, originals_directory, @ensemble.fit_filename, "fitted_SAXS_ensemble_with_model.dat") 
       puts "Filename #{@ensemble.fit_filename} "
       @ensemble.fit_filename = @ensemble.fit_filename.original_filename
       open(params[:ensemble][:fit_filename].tempfile.path){|f| fit_lines = f.readlines }
       @ensemble.fit_lines = fit_lines # non-Database model attribute (data_lines)
     end
    deleted = Array.new
    
    open(experiment_directory.join("ensemble.tmp")){|f| deleted = f.readlines } if File.exists?(experiment_directory.join("ensemble.tmp"))
    
    all_files = Array.new
    params[:ensemble_pdb].each do |x|
      all_files << x[0]
    end    
    
    params[:ensemble][:pdbfiles] = all_files.uniq - deleted.uniq  
    
     if @ensemble.valid? && Ensemble.presence_of?(:pdbfiles, params[:ensemble]) 
       #
       # write pdb files to ensemble directory using only those files not in ensemble.tmp
       # PDBs are in ensemble_pdb hash params[ensemble_pdb]
       # Modify summary.txt file
       #
       name = Array.new
       params[:ensemble_pdb].each do |x|
         if params[:ensemble][:pdbfiles].include?(x[0])
           uploadFile(ensemble_subdirectory, originals_directory, x[1], "#{x[0]}.pdb") 
           name << x[1].original_filename
         end
       end
       @ensemble.pdbfiles = name * ", "
       #
       # Save the image file to directory
       #
       @submission.diagnostic = params[:ensemble][:diagnostic]
       @submission.data_lines = fit_lines # non-Database model attribute (data_lines)       
       @submission.save
       #
       # Modify summary.txt file
       #
       experiment_directory.join("summary.txt")
       data_file = experiment_directory.join("summary.txt")
       data_lines = Array.new
       open(data_file){|f| data_lines = f.readlines}
       @experiment = build_experiment(data_lines, @submission.data_directory)
       @experiment.build_ensemble
       @ensemble.data_directory = @submission.data_directory    
       @experiment.ensemble = @ensemble
       
       Ensemble.make_fit_plot(fit_lines, experiment_directory)
       write_experiment(@experiment, @submission.data_directory)
       #remove temp file upon successful save
       File.delete(experiment_directory.join("ensemble.tmp"))if File.exists?(experiment_directory.join("ensemble.tmp"))

       
       flash[:notice] = "Ensemble Model Successful!"
       redirect_to add_models_path(@submission.data_directory) and return if @ensemble.valid?
     else   
       #
       # Delete files
       #
       if Dir.exists?(ensemble_subdirectory)
         files = Dir.entries(ensemble_subdirectory).select{|v| v =~ /^[^.]/}
         files.each do |file|
           File.delete("#{ensemble_subdirectory}/#{file}")
         end
         Dir.rmdir(ensemble_subdirectory)
       end             
       respond_to do |format|
         format.html { render :controller => 'submission', :action => 'add_ensemble_model', :id => params[:id] }         
       end     
     end
  
   end
   
   def destroy_ensemble_pdb
     @submission = Submission.find_by_data_directory(params[:id])  
     authorize! :manage, @submission        
     @targetdiv = params[:label]
     #
     # Maybe write destroy files to ensemble.tmp
     #
     open("#{Rails.root}/public/SAX_DATA/#{@submission.data_directory}/ensemble.tmp",'a'){|f| f << @targetdiv +"\n"}
     #
     respond_to do |format|
       format.html { redirect_to edit_submission_path(:id => @submission.data_directory) }
       format.js
     end
   end
   
   
   def destroy_ensemble_model
     #
     # remove from summary.txt file and delete directory and associated files summary.txt file.  
     # write new summary.txt file
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission        
     
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")
     experiment_directory = Rails.root.join("public","SAX_DATA",@submission.data_directory)      
     ensemble_subdirectory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "ensemble")       
     
     data_lines = Array.new
     # Open summary file
     open(data_file){|f| data_lines = f.readlines}
     # make Experiment
     @experiment = build_experiment(data_lines, @submission.data_directory) 
     #
     # Delete files and remove directory
     #
     if Dir.exists?(ensemble_subdirectory)
       files = Dir.entries(ensemble_subdirectory).select{|v| v =~ /^[^.]/}
       files.each do |file|
         File.delete("#{ensemble_subdirectory}/#{file}")
       end
       Dir.rmdir(ensemble_subdirectory)
     end

     File.delete(experiment_directory.join("med_res_ensemble_FIT.png")) if File.exists?(experiment_directory.join("med_res_ensemble_FIT.png"))
     #remove files from originals, including pdbs
     
     pdbfiles = @experiment.ensemble.pdbfiles.split(/,\s/)
     pdbfiles.each do |file|
        File.delete(experiment_directory.join("originals", file)) if File.exists? experiment_directory.join("originals", file)
     end
     File.delete(experiment_directory.join("originals", @experiment.ensemble.fit_filename)) if File.exists? experiment_directory.join("originals", @experiment.ensemble.fit_filename)
     @experiment.ensemble = nil     
     write_experiment(@experiment, @submission.data_directory)     
     redirect_to add_models_path(params[:id])
   end
   
   
   def add_no_model
      #
      # Open file if it exists and grab names
      #
      @submission = Submission.find_by_data_directory(params[:id])  
      authorize! :manage, @submission         
      @no_model = NoModel.new 
      respond_to do |format|
        format.html
      end    
   end
   
   def save_no_model
     @no_model = NoModel.new(params[:no_model])
     #
     # Modify summary.txt file : files are written to originals until experiment is approved
     #
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission        
     
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")
     nomodel_subdirectory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "nomodel")
     
     data_lines = Array.new
     open(data_file){|f| data_lines = f.readlines}     
     
     @experiment = build_experiment(data_lines, @submission.data_directory) 
     @experiment.build_no_model

     if @no_model.valid?
        #
        # save no model png to directory if available
        #       
        if !(Dir.exists?(nomodel_subdirectory) && !@no_model.figure_file_name.nil?)
          Dir.mkdir(nomodel_subdirectory) 
        end
        
        @experiment.no_model = @no_model 
        write_experiment(@experiment, @submission.data_directory)
        @submission.nomodel = params[:no_model][:figure]
        @submission.force_create = true    
        @submission.save
        redirect_to add_models_path(@submission.data_directory) and return if @no_model.valid?
     else
       respond_to do |format|
         format.html { render :controller => 'submission', :action => 'add_no_model', :id => params[:id] }         
       end     
     end            		                    		              
     
   end
   
   def destroy_no_model
     @experiment = Experiment.new
     @submission = Submission.find_by_data_directory(params[:id])
     authorize! :manage, @submission        
     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt") 
     nomodel_subdirectory = Rails.root.join("public","SAX_DATA",@submission.data_directory, "nomodel")              

     data_lines = Array.new
     # Open summary file
     open(data_file){|f| data_lines = f.readlines}
     # make Experiment
     @experiment = build_experiment(data_lines, @submission.data_directory) 
     #
     # Delete files and remove directory
     #
     if Dir.exists?(nomodel_subdirectory)
       files = Dir.entries(nomodel_subdirectory).select{|v| v =~ /^[^.]/}
       files.each do |file|
         File.delete("#{nomodel_subdirectory}/#{file}")
       end
       Dir.rmdir(nomodel_subdirectory)
     end     
     @submission.nomodel = nil
     @submission.force_create = true
     @submission.save
     @experiment.no_model = nil     
     write_experiment(@experiment, @submission.data_directory)     
     redirect_to add_models_path(params[:id])     
     
   end
   #
   # Final submission button, creator will no longer be able to edit submission 
   #
   def code_search
     @submission = Submission.find_by_data_directory(params[:id])
     puts "Hello from code search"
     authorize! :manage, @submission             
     if !(params[:commit] =~ Regexp.new(/Submit Data for Deposit/))
       @code =  params[:search]+params[:code_search][:code_termini]
       @ids = Experiment.search(@code)
       respond_to do |format|
         format.js 
       end
     elsif @submission.status && !Experiment.find_by_bioisis_id(params[:search]+params[:code_search][:code_termini])# 1 is true, 0 is false
        @submission = Submission.find_by_data_directory(params[:id])
        @submission.bioisis_id =  params[:search]+params[:code_search][:code_termini]
        @submission.status = 0
        @submission.force_create = true          
        if @submission.save   
          @experiment = Experiment.new   
          data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt")
          data_lines = Array.new
          open(data_file){|f| data_lines = f.readlines}
          @experiment = build_experiment(data_lines, @submission.data_directory)
          @experiment.bioisis_id = @submission.bioisis_id
          @experiment.email = @submission.email 
          write_experiment(@experiment, @submission.data_directory)          
          Notifier.deposit(@submission).deliver
          render :template => 'submissions/final' and return
        else
          redirect_to submission_edit_path(@submission.data_directory) and return
        end
     elsif Experiment.find_by_bioisis_id(params[:search]+params[:code_search][:code_termini])
          redirect_to submission_edit_path(@submission.data_directory) and return
     else
        render :template => 'submissions/submission_error' and return
     end    
   end
   
   def create_guinier
     @submission = Submission.find_by_data_directory(params[:id])
     @experiment = Experiment.new 
     directory = Rails.root.join("public", "SAX_DATA", @submission.data_directory)

     original_subdirectory = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "originals")    

     data_file = Rails.root.join("public","SAX_DATA",@submission.data_directory, "summary.txt") 
     tempfile = "#{directory}/temp.dat"     
     data_lines = Array.new
     open(data_file){|f| data_lines = f.readlines}
     @experiment = build_experiment(data_lines, @submission.data_directory)       
     limit = 1.3/@experiment.rg   # q*Rg < 1.3
     #
     # fit each seperately, find one closest to input Rg?
     #
     @files = Dir.glob("#{original_subdirectory}/*.dat.int")
     @functions = Hash.new
     count = 1     
     @files.each do |file|
         #
         # read in data 
         #
         datalines = Array.new
         path = "#{file}"        
         open(path){|f| datalines = f.readlines }        
         x_data = Array.new
         y_data = Array.new      
         w_data = Array.new

         selected = Array.new
         datalines.each do |f|
           data = f.strip.split(/[\s\t]+/)
           if f =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/ && !(f =~ /[a-z=]+/)
             if f.strip.split(/[\s\t]+/)[0].to_f < limit
               x_data << f.strip.split(/[\s\t]+/)[0].to_f*f.strip.split(/[\s\t]+/)[0].to_f
               y_data << Math.log(f.strip.split(/[\s\t]+/)[1].to_f)
               w_data << f.strip.split(/[\s\t]+/)[2].to_f
             end         
           end
         end
         #
         # Perform fit         
         if (x_data.size == 0 && @experiment.rg < 100) # implies we have nm instead of Angstrom           
           datalines.each do |f|
              data = f.strip.split(/[\s\t]+/)
              if f =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)[\s\t]+([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/ && !(f =~ /[a-z=]+/)
                x_value = f.strip.split(/[\s\t]+/)[0].to_f/10
                if x_value < limit
                  x_data << x_value*x_value
                  y_data << Math.log(f.strip.split(/[\s\t]+/)[1].to_f)
                  w_data << f.strip.split(/[\s\t]+/)[2].to_f
                end         
              end
            end           
         end
         
         constants = auto_fit(x_data, y_data, w_data)
         @functions["f#{count}(x)"] = "f#{count}(x) = #{constants["intercept"]} + #{constants["slope"]}*x"
         #
         # Make function for plot for gnuplot
         # Write out selected data to file as append
         #
         open(tempfile, 'a') do |f|
            x_data.each {|x| f << "#{x}\t#{y_data[x_data.index(x)]}\t#{w_data[x_data.index(x)]}\n" }
         end
         open(tempfile, 'a') do |f|
            f << "\n#\n\n"
         end         
         count += 1
     end
     Submission.make_Guinier(directory, @functions, tempfile)
     redirect_to approve_experiments_path(:id => @submission.data_directory)
                       
   end

   def active
     #
     # load submissions with status = 1
     #
     @submissions = Submission.paginate :per_page => 10, :page => params[:page], :conditions => ['status = 1'], :order => 'created_at'
     authorize! :manage, @submission
     respond_to do |format|
       format.html # index.html.erb
     end

   end
   
   def pending
     #
     # load submissions with status = 0 that do not have a corresponding entry in Experiments
     #
     @submissions = Submission.paginate(:per_page => 10, :page => params[:page], :conditions => ['status = 0 and bioisis_id NOT IN (select bioisis_id from experiments)'], :order => 'created_at')
     authorize! :manage, @submission
     respond_to do |format|
       format.html # index.html.erb
     end

   end

   private
   def nice_date(date)
     h date.strftime("%d %B %Y")
   end
   
    

end
