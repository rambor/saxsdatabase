module ToFile
    
    def uploadFile(directory, subdirectory, uploaded_file, new_file_name)
      name = uploaded_file.original_filename 
      path = File.join(subdirectory, name)

      newpath = File.join(directory, new_file_name)        
      File.open(path, "w"){|f| f.write(uploaded_file.tempfile.read)}

      if new_file_name =~ /(average|single)_(dammin|gasbor)_model.pdb/
        #
        # Open file and extract the relevant pdb information, have to remove non header information
        #
        file_lines = Array.new
        open(path){|f| file_lines = f.readlines}
        open(newpath,'w') do |f|
          file_lines.each do |i|
            if ((i =~ /^ATOM/) && (i =~ /ASP/))
              puts i
              f << i
            end
          end
          f << "END\n"
        end
      else  
        FileUtils.copy_file(path, newpath)        
      end  
      
    end
      
      
      
    def write_experiment(experiment, data_directory)
     #
     # Write file elements to array
     #
     experiment.description = !experiment.description.nil? ? experiment.description.gsub(/[\n\r\t]+/,"\s").chomp("\s") : ""
     experiment.publication = !experiment.publication.nil? ? experiment.publication.gsub(/[\n\r\t]+/,"\s").chomp("\s") : ""
     experiment.experimental_details = !experiment.experimental_details.nil? ? experiment.experimental_details.gsub(/[\n\r\t]+/,"") : ""     
          
     summary_array = Array.new     
     summary_array << "#REMARK USER INFORMATION \n"
   	 summary_array << "DATA_DIRECTORY\t#{data_directory}\n"
     summary_array << "EMAIL\t\t#{experiment.email}\n"
     summary_array << "CREATED_ON\t#{experiment.created_at}\n"     
   	 summary_array << "\n"
   	 summary_array << "#REMARK SUMMARY\n"
   	 summary_array << "TITLE\t#{experiment.title}\n"
     summary_array << "BIOISIS_ID\t#{experiment.bioisis_id}\n"   	 	 
   	 summary_array << "EXP_DESCRIPTION\t#{experiment.description}\n"
   	 summary_array << "SOURCE_LOCATION\t#{experiment.source_location}\n"	 
   	 summary_array << "PUBLICATION\t#{experiment.publication}\n"
   	 summary_array << "\n"	 
   	 summary_array << "#REMARK EXPERIMENTAL CONDITIONS\n"	 
   	 summary_array << "EXPERIMENTAL_DETAILS\t#{experiment.experimental_details}\n"
   	 summary_array << "BUFFER\t\t\t#{experiment.buffer.chomp}\n"
   	 summary_array << "pH\t\t\t#{experiment.pH}\n"	 		  
   	 summary_array << "TEMPERATURE\t\t#{experiment.temp}\n"
   	 summary_array << "SALT\t\t\t#{experiment.salt.chomp}\n"	 		  
   	 summary_array << "SALT_CONCENTRATION\t#{experiment.salt_concentration}\n"
   	 summary_array << "DIVALENT\t\t#{experiment.divalent.chomp}\n"	 		  
   	 summary_array << "DIVALENT_CONCENTRATION\t#{experiment.divalent_concentration}\n"
   	 summary_array << "ADDITIVES\t\t#{experiment.additives}\n"	  
   	 summary_array << "PROTEIN\t\t\t#{experiment.protein ? "Yes": "No"}\n"
   	 summary_array << "DNA\t\t\t#{experiment.dna ? "Yes" : "No"}\n"
   	 summary_array << "RNA\t\t\t#{experiment.rna ? "Yes" : "No"}\n"
   	 summary_array << "MEMBRANE\t\t#{experiment.membrane ? "Yes" : "No"}\n"
   	 summary_array << "NANOPARTICLE\t\t#{experiment.nanoparticle ? "Yes" : "No"}\n"   	    	    	    	 	 		  
   	 summary_array << "\n"
   	 summary_array << "#REMARK EXPERIMENTAL VALUES\n"	 		  
   	 summary_array << "Io\t\t\t#{experiment.io}\n"
   	 summary_array << "SIG_Io\t\t\t#{experiment.sig_Io}\n"	 		  
   	 summary_array << "Io_MOLECULAR_WEIGHT\t#{experiment.io_molecular_weight}\n"
   	 summary_array << "DMAX\t\t\t#{experiment.dmax}\n"	 		  
   	 summary_array << "RG\t\t\t#{experiment.rg}\n"
   	 summary_array << "SIG_RG\t\t\t#{experiment.sig_Rg}\n"	 		  
   	 summary_array << "RG_REAL\t\t\t#{experiment.rg_real}\n"
   	 summary_array << "SIG_RG_REAL\t\t#{experiment.sig_Rg_real}\n"	 		  
   	 summary_array << "V_POROD\t\t\t#{experiment.v_porod}\n"
   	 summary_array << "V_C\t\t\t#{experiment.volume_of_correlation}\n"
   	 summary_array << "POROD_EXPONENT\t\t#{experiment.porod_exponent}\n"
   	 summary_array << "\n"
   	 #
   	 # Write out authors
   	 # If no authors are set, authors.empty? returns true
   	 #
   	 if !(experiment.authors.empty?)
     	 summary_array << "#REMARK AUTHORS\n"	 		  
    	 experiment.authors.each do |author|
         #
  	     summary_array << "AUTHOR\t#{author.lastname.chomp}\t\t#{author.initials.chomp}\n"
         #
  	   end
  	     summary_array << "\n"  	   
 	   end
  	 #
   	 # Write out genes
   	 #
   	 if !(experiment.expgenes.empty?)
     	 summary_array << "#REMARK BIO | POLYMER INFORMATION\n"
     	 count = 1	 		  
    	 experiment.expgenes.each do |gene|
  	     summary_array << "INFO_#{count}\n"
  	     summary_array << "ABBR_NAME\t#{gene.abbr_name}\n"
  	     summary_array << "EXP_MW\t\t#{gene.exp_mw}\n"
     		 summary_array << "ANNOTATION\t#{gene.annotation.gsub(/\r\n/,"\s").chomp("\s")}\n"
     		 summary_array << "EXP_SEQUENCE\t#{gene.experimental_sequence}\n"    
   	     summary_array << "\n"   		 		 
  #   		 count = 0
  #   		 until count == gene.experimental_sequence.scan(/............................................................/).size
  #   		   summary_array << "EXP_SEQUENCE\t#{gene.experimental_sequence[count*60,60]}\n"
  #   		   count += 1
  #   		 end
  #   		 if (gene.experimental_sequence.length - gene.experimental_sequence.length/60*60)  > 0 
  #   		   summary_array << "EXP_SEQUENCE\t#{gene.experimental_sequence.slice(gene.experimental_sequence.length/60*60..gene.experimental_sequence.length)}\n"
  #   		 end 	     
  #	     summary_array << "\n"    	         	     	       	     
         #
         count += 1
       end       
 	   end	    	   
     #
     # DAMMIN RESULT
     #
     if !experiment.dammin_result.nil?
        summary_array << "\n#REMARK DAMMIN\n"		       
        summary_array << "SPACEGROUP\t\t#{experiment.dammin_result.spacegroup}\n"
        summary_array << "NSD\t\t\t#{experiment.dammin_result.nsd}\n"
        summary_array << "STDEV_NSD\t\t#{experiment.dammin_result.sig_NSD}\n"          
        summary_array << "AVERAGE_OF\t\t#{experiment.dammin_result.number_in_average}\n\n"
     end
     
     
     if !experiment.gasbor_results[0].nil?
        summary_array << "\n#REMARK GASBOR\n"		       
        summary_array << "SPACEGROUP\t\t#{experiment.gasbor_results[0].spacegroup}\n"
        summary_array << "NSD\t\t\t#{experiment.gasbor_results[0].nsd}\n"
        summary_array << "STDEV_NSD\t\t#{experiment.gasbor_results[0].sig_NSD}\n"          
        summary_array << "AVERAGE_OF\t\t#{experiment.gasbor_results[0].number_in_average}\n"
        summary_array << "CHI_SQUARE\t\t#{experiment.gasbor_results[0].chi_square}\n\n"
     end
     
     if !experiment.structural_model.nil?
        summary_array << "\n#REMARK STRUCTURAL MODEL\n"		       
        summary_array << "CHI_SQUARE\t\t#{experiment.structural_model.chi_square}\n"
        summary_array << "FIT_FILENAME\t\t#{experiment.structural_model.fit_filename}\n"                                                
        summary_array << "DESCRIPTION\t\t#{experiment.structural_model.description.gsub(/[\n\r]+/,'<br/>').chomp("\s")}\n"
     end
     
     if !experiment.ensemble.nil?
        summary_array << "\n#REMARK ENSEMBLE MODEL\n"		       
        summary_array << "SCORING_FUNCTION\t#{experiment.ensemble.scoring_function}\n"
        summary_array << "SCORE\t\t\t#{experiment.ensemble.score}\n"        
        summary_array << "SELECTION_METHOD\t#{experiment.ensemble.selection_method}\n"
        summary_array << "SIMULATION_METHOD\t#{experiment.ensemble.simulation_method}\n"
        summary_array << "SIMULATION_ALGORITHM\t#{experiment.ensemble.simulation_algorithm}\n"        
        summary_array << "FIT_FILENAME\t\t#{experiment.ensemble.fit_filename}\n"                                                
        summary_array << "ENSEMBLE_SIZE\t\t#{experiment.ensemble.ensemble_size}\n"
        summary_array << "MEMBER_SIZE\t\t#{experiment.ensemble.member_size}\n"
        summary_array << "DIAGNOSTIC_LEGEND\t\t#{experiment.ensemble.figure_legend.gsub(/[\n\r]+/,'<br/>').chomp("\s")}\n"        
     end
     
     if !experiment.no_model.nil?
        summary_array << "\n#REMARK NO MODEL\n"		       
        summary_array << "DESCRIPTION\t#{experiment.no_model.description.gsub(/[\n\r]+/,'<br/>').chomp("\s")}\n"        
     end
      	   
     summary_array << "\n#REMARK\tALL UPLOADED FILES ARE RENAMED\n#REMARK\tUSE THE FOLLOWING KEY TO DETERMINE THE ORIGINAL UPLOADED FILE(S).\n#REMARK\n"
     summary_array << "# RENAMED FILE\t\t\tORIGINAL FILE\n"
     #
   	 # Add original files
   	 #
   	 if !experiment.iofq_file_name.nil? 
       summary_array <<  "iofq_data_file\t\t\toriginals\/#{experiment.iofq_file_name}\n"	 		  
     end
     #
     if !experiment.pofr_file_name.nil?
       summary_array << "pofr_data_file\t\t\toriginals\/#{experiment.pofr_file_name}\n"	 		  
     end
     
     if !experiment.dammin_result.nil?
     	 summary_array << "single_dammin_model.pdb\t\tdammin/#{experiment.dammin_result.single_model_filename}\n"
       summary_array << "average_dammin_model.pdb\tdammin/#{experiment.dammin_result.average_model_filename}\n"
       if !experiment.dammin_result.subcomb_model.nil?
          summary_array << "hires_dammin_model.pdb\t\tdammin/#{experiment.dammin_result.subcomb_model}\n"            	           
       end
     end
     
     if !experiment.gasbor_results.empty?
     	 summary_array << "single_gasbor_model.pdb\t\tgasbor/#{experiment.gasbor_results[0].single_model_filename}\n"
       summary_array << "average_gasbor_model.pdb\tgasbor/#{experiment.gasbor_results[0].average_model_filename}\n"
       if !experiment.gasbor_results[0].subcomb_model.nil?
          summary_array << "hires_gasbor_model.pdb\t\tgasbor/#{experiment.gasbor_results[0].subcomb_model}\n"            	           
       end
     end
     
     if !experiment.structural_model.nil?       
       summary_array << "fitted_SAXS_with_model.dat\tstructure/#{experiment.structural_model.fit_filename}\n"
       summary_array << "pdb_model.pdb\t\t\tstructure/#{experiment.structural_model.pdb_filename}\n"               
     end

     if !experiment.ensemble.nil?       
       summary_array << "fitted_SAXS_ensemble_with_model.dat\t\toriginals\/#{experiment.ensemble.fit_filename}\n"    
       summary_array << "pdb_filename_ .pdb\t\t\toriginals\/#{experiment.ensemble.pdbfiles}\n"           
     end
     
     if !experiment.no_model.nil? && (experiment.no_model.figure_file_name != "NOT PROVIDED")
       summary_array << "no_model_image_\t\t\toriginals\/#{experiment.no_model.figure_file_name}\n"           
#       summary_array << "no_model_image_\t\t\toriginals\/#{experiment.no_model.nomodel_file_name}\n"                  
     end
   	 #
   	 # WRITE TO FILE (this will over-write existing file)
   	 # Rails.root.join("public", "SAX_DATA", data_directory, "summary.txt")
   	 open(Rails.root.join("public", "SAX_DATA", data_directory, "summary.txt"), 'w') do |f|   	 
         summary_array.each {|i| f << i }
     end
   	 
    end
    
end