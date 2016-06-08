module IofqFilename

    def make_iofq_filename(submission)

      original_subdirectory = Rails.root.join("public", "SAX_DATA", submission.data_directory, "originals")      
      files = Dir.glob("#{original_subdirectory}/*.dat.int")            
      #
      # Open summary.txt if it exists and read in information
      #
      @experiment = Experiment.new
      data_file = Rails.root.join("public", "SAX_DATA", submission.data_directory, "summary.txt")
#      data_file = "#{RAILS_ROOT}/public/SAX_DATA/#{submission.data_directory}/summary.txt"
      if File.exists? data_file
        #
        # Open summary.txt and read in for filling in form
        #
        data_lines = Array.new
        open(data_file){|f| data_lines = f.readlines}
        @experiment = build_experiment(data_lines, submission.data_directory)         
      else
        #
        # Create new summary file and write out array elements
        #
        @experiment = Experiment.new(params[:experiment])
        # @experiment.experimental_date = DateTime.now # Summary.txt creation date, different from database approval or alteration date
        @experiment.ip_address = request.remote_ip
        @experiment.email = submission.email
      end
      #
      # Make file name for summary file iofq_file_name
      #         
      name = String.new
      files.each do |file|
        if files.index(file) == 0
            name = file.split(/originals\//)[1].split(/\.int/)[0]
        elsif files.index(file) > 0 # make comma separated file name
            name = name + ", " + file.split(/originals\//)[1].split(/\.int/)[0]
        end
      end
      # Update the experiment
      @experiment.iofq_file_name = name
      #
      # Write out new summary file
      #
      write_experiment(@experiment, submission.data_directory)      

   end
end