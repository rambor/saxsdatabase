class ExperimentsController < ApplicationController
   include ToFile
   include FromFile   
  # GET /experiments
  # GET /experiments.xml
  def index
    #@experiments = Experiment.all
    @experiments = Experiment.paginate :per_page => 5, :page => params[:page], :order => "id DESC", :conditions => ['status=1']
    @datasets=[]
    @experiments.each do |exp|
      @datasets << createThumbJSON(Rails.root.join("public","SAX_DATA", exp.data_directory, "iofq_data_file.dat")) 
    end
    
    respond_to do |format|
      format.html { render :action => "list"} # index.html.erb
      format.xml  { render :xml => @experiments }
    end
  end
  
  def filter #use this to display the first page with 5 random structures
      id=params[:id].to_i
      if id==1
        # depends on sql RAND function - might create portability issues
        # @experiments = Experiment.find(:all, :order => 'RAND()', :limit=>5)
        @experiments = Experiment.paginate :per_page =>5, :page => params[:page], :order => 'RAND()', :limit =>5, :conditions => ['status=1']
      elsif id==2
        # Experiment.find(:all, :include=>[:genes], :conditions=>"annotation LIKE \'%hypothetical%\'")
        @experiments = Experiment.paginate :per_page =>5, :page => params[:page], :include=>[:genes], :conditions=>"genes.annotation LIKE \'%hypothetical%\' AND status=1", :order => 'experiments.created_at DESC'
      elsif id==3
        @experiments = Experiment.paginate :per_page =>5, :page => params[:page], :include=>[:expgenes, :genes], :conditions=>"experiments.status = 1 AND expgenes.annotation LIKE \'%RNA%\' OR expgenes.annotation LIKE \'%riboswitch%\' OR genes.annotation LIKE \'%RNA%\' OR RNA = 1", :order => 'experiments.created_at DESC'
      end

      @datasets=[]
      @experiments.each do |exp|
        @datasets << createThumbJSON(Rails.root.join("public","SAX_DATA", exp.data_directory, "iofq_data_file.dat")) 
      end
      respond_to do |format|
        format.html { render :action => "list"} # index.html.erb
        format.xml  { render :xml => @experiments }
      end

  end
  # GET /experiments/1
  # GET /experiments/1.xml
 
  def categories
      # list results from search results piped in from side nav categories
    @experiments = Experiment.find(:status => true)
    respond_to do |format|
      format.html { render :action => "list" }
      format.xml  { render :xml => @experiments }
    end

  end

  def details
    @experiment = Experiment.find(params[:id])
    @current_directory = Dir.pwd    
    # open file and read in data for plotting
    iofq_file = "#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/iofq_data_file.dat"
    pofr_file = "#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/pofr_data_file.dat"
    fit_file = "#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/fitted_SAXS_with_model.dat"
   
    @iofq_data =[]
    @kratky_data =[]    
    @pofr_data =[]
    @fit_data =[]
    @guinier_data =[]    
    #

    if File.exists? iofq_file
       #
       # Private method at bottom loadFileIntoJSON()
       @iofq_data, @qmax = loadFileIntoJSON(iofq_file, true)
       #create Kratky data
       @kratky_data = createKratky(iofq_file, @qmax)
       #create Guinier region q*Rg < 1.3
       @guinier_data, @low, @upper = createGuinier(iofq_file, @experiment.rg, @experiment.io)       
    end

    if File.exists? pofr_file
       #
       #
       @pofr_data, @rmax = loadFileIntoJSON(pofr_file, false)
    end

    if File.exists? fit_file
       #
       #  
       @fit_data, @fqmax = loadFileIntoJSON(fit_file, true)
    end

    respond_to do |format|
       format.html { render 'details' }     
       #format.any { render 'details', :formats => [:js], :content_type =>"text/javascript" }   
       #format.js
    end

  end
  

  # GET /experiments/new
  # GET /experiments/new.xml
  def new
    #
    # Grab the directory number in link from email, check against email address and code in link
    #
    # Open page and load from directory
    #
    @experiment = Experiment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @experiment }
    end
  end

  # GET /experiments/1/edit
  def admin_list
    @experiments = Experiment.paginate :per_page => 20, :page => params[:page], :order => "id DESC"
    authorize! :manage, @experiments
    respond_to do |format|
      format.html { render :action => "admin_list" } # new.html.erb
      format.xml  { render :xml => @experiment }
    end    
  end
  
  
  def edit
    @experiment = Experiment.find(params[:id]) 
    @iofq_data =[]
    @kratky_data =[]    
    @pofr_data =[]
    @fit_data =[]
    @guinier_data =[]
        
    if @experiment.thumbnail.nil?
      @experiment.build_thumbnail    
    end

    iofq_file = "#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/iofq_data_file.dat"
    pofr_file = "#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/pofr_data_file.dat"
    fit_file = "#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/fitted_SAXS_with_model.dat"
    zip_file = "#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/BID_#{@experiment.bioisis_id}.zip"
        
    if File.exists? iofq_file
       #
       # Private method at bottom loadFileIntoJSON()
       @iofq_data, @qmax = loadFileIntoJSON(iofq_file, true)
       #create Kratky data
       @kratky_data = createKratky(iofq_file, @qmax)
       #create Guinier region q*Rg < 1.3
       @guinier_data, @low, @upper = createGuinier(iofq_file, @experiment.rg, @experiment.io)       
    end

    if File.exists? pofr_file
       #
       #
       @pofr_data, @rmax = loadFileIntoJSON(pofr_file, false)
    end

    if File.exists? fit_file
       #
       #  
       @fit_data, @fqmax = loadFileIntoJSON(fit_file, true)
    end

    @zip_updated = "No Zip file created"
        
    if File.exists? zip_file
      @zip_file = zip_file
      @zip_updated = File.mtime(zip_file).strftime("Zip updated on %m/%d/%Y")
    end
    puts "EXPGENES________________________________________"
    @experiment.expgenes.each do |gene|
      puts "dots: #{gene.annotation.split(/\./).size}"
      puts "\s #{gene.annotation.split(/\s/).size}"
      if (gene.annotation.split(/\./).size >= gene.annotation.split(/\s/).size)
        # gene.annotation.gsub!("..", "*").gsub!(".", " ").gsub!("*",".")
      end
    end
        
    @originals = Dir.glob("#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/originals/*.int")
    
    if !@experiment.structural_model.nil?
        @experiment.structural_model.force_create = true    
    end
    
    if !@experiment.ensemble.nil?
        @experiment.ensemble.force_create = true    
        @extension = @experiment.ensemble.diagnostic_content_type.split(/\//)[1]
        ensemble_directory = "#{Rails.root}/public/SAX_DATA/" + @experiment.data_directory + "/ensemble"                 
        #
        # open ensemble directory and grab all *.pdb files
        #
        @pdbs = Array.new
        @pdbs = Dir.glob("#{ensemble_directory}/*.pdb")        
    end    
    
    if !@experiment.no_model.nil?
        @experiment.no_model.force_create = true    
        if !@experiment.no_model.figure_content_type.nil?
           @extension = @experiment.no_model.figure_content_type.split(/\//)[1]        
        end
    end
     
    authorize! :manage, @experiments      
    respond_to do |format|
      format.html 
    end    
    
  end

  # POST /experiments
  # POST /experiments.xml
  def create
    @experiment = Experiment.new(params[:experiment])
    authorize! :manage, @experiments
    data_file = "#{Rails.root.to_s}/public/SAX_DATA/#{@experiment.data_directory}/summary.txt"    
    @experiment.id = nil

    #
    if !@experiment.structural_model.nil?
        @experiment.structural_model.data_directory = @experiment.data_directory 
        @experiment.structural_model.force_create = true              
    end

    if !@experiment.ensemble.nil?
        submission = Submission.find_by_data_directory(@experiment.data_directory)
        ensemble_directory = Rails.root.join("public","SAX_DATA", @experiment.data_directory, "ensemble")                    
        @experiment.ensemble.data_directory = ensemble_directory
        #
        # open ensemble directory and grab all *.pdb files
        #
        @experiment.ensemble.diagnostic_file_name = submission.diagnostic_file_name
        @experiment.ensemble.diagnostic_file_size = submission.diagnostic_file_size
        @experiment.ensemble.diagnostic_content_type = submission.diagnostic_content_type 
#          @diag_extension = @submission.diagnostic_content_type.split(/\//)[1]

        @extension = !(@experiment.ensemble.diagnostic_content_type.nil?) ? @experiment.ensemble.diagnostic_content_type.split(/\//)[1] : nil                                     

        @pdbs = Array.new
        @pdbs = Dir.glob("#{ensemble_directory}/*.pdb")         
    end    
    if !@experiment.no_model.nil?
        @experiment.no_model.data_directory = @experiment.data_directory    
    end
    if !@experiment.dammin_result.nil?
        @experiment.dammin_result.data_directory = @experiment.data_directory    
    end    
    if !@experiment.gasbor_results.empty?
        @experiment.gasbor_results[0].data_directory = @experiment.data_directory    
    end    
        
    respond_to do |format|
      if @experiment.save
        write_experiment(@experiment, @experiment.data_directory)
        # remove from submissions
        format.html { redirect_to :action=> 'admin_list', :notice => 'Experiment was successfully created.' }
      else        
       
        flash[:notice] = @experiment.errors.inspect
        #@experiment.id = Experiment.find(:first, :order => "id DESC").id + 1 
        format.html { redirect_to approve_experiments_path(:id => @experiment.data_directory) }        
      end
    end
    
  end

  # PUT /experiments/1
  # PUT /experiments/1.xml
  def update
    @experiment = Experiment.find(params[:id])
    authorize! :manage, @experiments    
    #
    # if genes are associated with experiment but not expgenes,then copy over and write to directoy
    #
    # Need to update Summary file
    # 
    @iofq_data =[]
    @kratky_data =[]    
    @pofr_data =[]
    @fit_data =[]
    @guinier_data =[]

    iofq_file = "#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/iofq_data_file.dat"
    pofr_file = "#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/pofr_data_file.dat"
    fit_file = "#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/fitted_SAXS_with_model.dat"
    
    if File.exists? iofq_file
       #
       # Private method at bottom loadFileIntoJSON()
       @iofq_data, @qmax = loadFileIntoJSON(iofq_file, true)
       #create Kratky data
       @kratky_data = createKratky(iofq_file, @qmax)
       #create Guinier region q*Rg < 1.3
       @guinier_data, @low, @upper = createGuinier(iofq_file, @experiment.rg, @experiment.io)       
    end

    @pofr_data, @rmax = loadFileIntoJSON(pofr_file, false) if File.exists? pofr_file
    @fit_data, @fqmax = loadFileIntoJSON(fit_file, true) if File.exists? fit_file
    
    @originals = Dir.glob("#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/originals/*.int")    
    if !@experiment.structural_model.nil?
        @experiment.structural_model.force_create = true    
    end
    if !@experiment.ensemble.nil?
        @experiment.ensemble.force_create = true    
    end    
    if !@experiment.no_model.nil?
        @experiment.no_model.force_create = true
        if !@experiment.no_model.figure_content_type.nil?    
          @extension = @experiment.no_model_content_type.split(/\//)[1]
        end        
    end 
  
    respond_to do |format|
      if @experiment.update_attributes(params[:experiment])
        write_experiment(@experiment, @experiment.data_directory)  
        format.html { redirect_to(edit_experiment_path(@experiment.id), :notice => 'Experiment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @experiment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def approve
    @experiment = Experiment.new
    @submission = Submission.find_by_data_directory(params[:id])
    @originals = Dir.glob("#{Rails.root}/public/SAX_DATA/#{@submission.data_directory}/originals/*.int")    
    authorize! :manage, @experiments    
    #
    @fit_data =[]
    @guinier_data =[]    
    @iofq_data =[]
    @kratky_data =[]    
    @pofr_data =[]
    @rmax = 0.0
    @qmax = 0.0
    
    iofq_file = Rails.root.join("public", "SAX_DATA", @submission.data_directory,"iofq_data_file.dat")
    pofr_file = Rails.root.join("public", "SAX_DATA", @submission.data_directory,"pofr_data_file.dat")    
    if File.exists?(iofq_file)
      @iofq_data, @qmax = loadFileIntoJSON(iofq_file, true)
      @kratky_data = createKratky(iofq_file, @qmax)
    end
    
    @pofr_data, @rmax = loadFileIntoJSON(pofr_file, false) if File.exists? pofr_file

    data_file = Rails.root.join("public", "SAX_DATA", @submission.data_directory, "summary.txt")

    if File.exists? data_file
       #
       # Open summary.txt and read in for filling in form
       #
       data_lines = Array.new
       open(data_file){|f| data_lines = f.readlines}
       @experiment = build_experiment(data_lines, @submission.data_directory) 
       @experiment.email = @submission.email 
       @experiment.id = Experiment.find(:first, :order => "id DESC").id + 1   # returns the next available ID
       # This have to be hidden
       if !@experiment.no_model.nil?
         @experiment.no_model.figure_file_name = @submission.nomodel_file_name
         @experiment.no_model.figure_file_size = @submission.nomodel_file_size
         @experiment.no_model.figure_content_type = @submission.nomodel_content_type 
         @extension = !(@submission.nomodel_content_type.nil?) ? @submission.nomodel_content_type.split(/\//)[1] : nil
       end 
       
       puts "EXPGENES________________________________________"
       @experiment.expgenes.each do |gene|
         puts "dots: #{gene.annotation.split(/\./).size}"
         puts "\s #{gene.annotation.split(/\s/).size}"
         if (gene.annotation.split(/\./).size >= gene.annotation.split(/\s/).size)
           #gene.annotation.gsub!("..", "*").gsub!(".", " ").gsub!("*",".")
         end
       end       
       
       if !@experiment.ensemble.nil?
         @experiment.ensemble.diagnostic_file_name = @submission.diagnostic_file_name
         @experiment.ensemble.diagnostic_file_size = @submission.diagnostic_file_size
         @experiment.ensemble.diagnostic_content_type = @submission.diagnostic_content_type 

         @extension = !(@submission.diagnostic_content_type.nil?) ? @submission.diagnostic_content_type.split(/\//)[1] : nil         
         if @extension == 'tiff'
           @extension = "tif"
           @experiment.ensemble.diagnostic_content_type = 'tif'
         elsif @extension == 'jpeg'
           @extension = "jpg"
         end   
         ensemble_directory = Rails.root.join("public","SAX_DATA", @experiment.data_directory, "ensemble")
         #
         # open ensemble directory and grab all *.pdb files
         #
         @pdbs = Array.new
         @pdbs = Dir.glob("#{ensemble_directory}/*.pdb")
       end  
       render :action => "edit" #and return if @.valid?       
    else
       redirect_to :controller=>"submissions", :action=>"pending"
    end    
  end


  
  def create_zip
    @experiment = Experiment.find(params[:id])
    # Delete zip file if available
    files = Dir.glob("#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/*.zip")
    if files.size > 0
      files.each do |file|
        File.delete(file)
      end
    end
    # Move to directory and make zip file
    Dir.chdir("#{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/") do
      system("zip #{Rails.root}/public/SAX_DATA/#{@experiment.data_directory}/BID_#{@experiment.bioisis_id} * originals/* -x \*.plt")
    end
    redirect_to :action=>'edit', :id=>@experiment.id
  end
  
  def download
    experiment = Experiment.find(params[:id])
    direct_file = "#{Rails.root}/public/SAX_DATA/#{experiment.data_directory}/BID_#{experiment.bioisis_id}.zip"
    # temp=GeoKit::Geocoders::IpGeocoder.geocode(request.remote_ip) 
    #
    # Open downloaded text file and add new entry ID, IP_address, Date, Location 
    #

    File.open("#{Rails.root}/public/downloaded.txt", "a"){|f| f << sprintf("%4.0d\t%s\t%s\n", params[:id].to_i, request.remote_ip.to_s, Time.now.strftime("%Y-%m-%d")) }    
    if File.exist?(direct_file) #if file doesn't exist, create the zip archive for downloading
        send_file(direct_file, :x_sendfile => true, :filename => "BID_#{experiment.bioisis_id}.zip")
    end
  end  
  
  def download_original
    experiment = Experiment.find(params[:id])
    datafile = params[:file]    
    file = datafile.split(/originals\//)[1]
    if File.exist?(datafile) #if file doesn't exist, create the zip archive for downloading
        send_file(datafile, :x_sendfile => true, :filename => file)
    end    
  end
  
  
  def download_data
    experiment = Experiment.find(params[:id])
    datafile = params[:file]
    file = case datafile
       when "average_dammin" then "average_dammin_model.pdb"
       when "single_dammin" then "single_dammin_model.pdb"
       when "average_gasbor" then "average_gasbor_model.pdb"
       when "single_gasbor" then "single_gasbor_model.pdb"
       when "iofq" then "iofq_data_file.dat"
       when "structure" then "pdb_model.pdb"
       when /pdb_filename_[0-9]+/ then datafile.split(/#{experiment.data_directory}\//)[1]
    end
    direct_file = "#{Rails.root}/public/SAX_DATA/#{experiment.data_directory}/#{file}"
    # temp=GeoKit::Geocoders::IpGeocoder.geocode(request.remote_ip) 
    #
    # Open downloaded text file and add new entry ID, IP_address, Date, Location 
    #
    # File.open("#{Rails.root}/public/downloaded.txt", "a"){|f| f << sprintf("%4.0d\t%s\t%s\t%s\n", params[:id].to_i, request.remote_ip.to_s, Time.now.strftime("%Y-%m-%d"), temp.full_address) }
    if File.exist?(direct_file) #if file doesn't exist, create the zip archive for downloading
        send_file(direct_file, :x_sendfile => true, :filename => file)
    end
  end
  
  private

  def createGuinier(filename, rg, io)
    limit = 1.3/rg
    tempArray = Array.new
    myDataArray = Array.new
    x =[]
    y =[]
    
    open(filename){|f| tempArray = f.readlines}
    tempArray.each do |line|
      # split the line
      values = line.lstrip.split(/[\t\s]+/)

      if (values[0] =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/) && (values[1] =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/) 
         q = values[0].to_f
         if (q <= limit)
           x << q*q
           y << (Math.log(values[1].to_f))
         end
      end
    end
    
    if (x.size == 0) && (rg < 100)
     # assume nm for x-axis and convert
     open(filename){|f| tempArray = f.readlines}        
     tempArray.each do |line|
       # split the line
       values = line.lstrip.split(/[\t\s]+/)
       if (values[0] =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/) && (values[1] =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/) 
          q = values[0].to_f/10
          if (q <= limit)
            x << q*q
            y << (Math.log(values[1].to_f))
          end
       end
     end
     
     # convert to Angstroms and write new file
     lines=[]
     tempArray.each do |line|
       # split the line
       values = line.lstrip.split(/[\t\s]+/)
       if (values[0] =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/) && (values[1] =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/) 
          lines<<"#{values[0].to_f/10} #{values[1]} #{values[2]}\n"
       end
     end
     open(filename, 'w'){|x| lines.each {|f| x << f}}
     
    end
  
    xmin = x.min    
    xmax = x.max
    
    xconst = 345/(xmax - xmin)

    ymin = y.min    
    y_max= y.max
    ymax = y_max*0.02 + y_max            
    yconst = 270/(ymin - ymax)
    
    x.each_index do |ele|
         myDataArray << "{x:#{(x[ele]-xmin)*xconst + 30}, y:#{(y[ele] - ymax)*yconst} }"          
    end

    
    lowy = Math.log(io) - rg*rg/3*xmin
    low = "{x: #{(xmin-xmin)*xconst + 30}, y: #{(lowy - ymax)*yconst} }"
    
    uppery = Math.log(io) - rg*rg/3*xmax
    upper = "{x: #{(xmax-xmin)*xconst + 30}, y: #{(uppery - ymax)*yconst} }"    
    return myDataArray, low, upper
    
  end
  
end
