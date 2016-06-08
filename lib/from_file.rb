module FromFile

    def build_experiment(data_lines, data_directory)
      @experiment = Experiment.new(:data_directory => data_directory)
      data_lines.each do |line|
        
        case                    
          when line.match(/^TITLE/)                                                       
            @experiment.title=line.split(/\t+/)[1]
          when line.match(/^EXP_DESCRIPTION/)  
            @experiment.description=line.split(/\t+/)[1]           
          when line.match(/^BIOISIS_ID/)   
            @experiment.bioisis_id=line.split(/\t+/)[1]
          when line.match(/^SOURCE_LOCATION/)
            @experiment.source_location=line.split(/\t+/)[1]
          when line.match(/^PUBLICATION/)  
            @experiment.publication=line.split(/\t+/)[1]
          when line.match(/^CREATED_ON/)  
            @experiment.created_at=line.split(/\t+/)[1]          
          when line.match(/^EXPERIMENTAL_DETAILS/)                                                       
            @experiment.experimental_details=line.split(/\t+/)[1]
          when line.match(/^BUFFER/)  
            @experiment.buffer=line.split(/\t+/)[1]           
          when line.match(/^pH/)   
            @experiment.pH=line.split(/\t+/)[1]
          when line.match(/^TEMPERATURE/)
            @experiment.temp=line.split(/\t+/)[1]
          when line.match(/^SALT/)  && !(line.match(/^SALT_CONCENTRATION/))
            @experiment.salt=line.split(/\t+/)[1]
          when line.match(/^SALT_CONCENTRATION/)                                                                                                     
            @experiment.salt_concentration=line.split(/\t+/)[1]
          when line.match(/^DIVALENT/)  && !(line.match(/^DIVALENT_CONCENTRATION/))
            @experiment.divalent=line.split(/\t+/)[1]
          when line.match(/^DIVALENT_CONCENTRATION/)
            @experiment.divalent_concentration=line.split(/\t+/)[1]
          when line.match(/^ADDITIVES/)
            @experiment.additives=line.split(/\t+/)[1]
          when line.match(/^RNA/)
            #
            if line.split(/\t+/)[1] =~ /Yes/
              @experiment.rna=1           
            else
              @experiment.rna=0           
            end
            #            
          when line.match(/^DNA/)
            #
            if line.split(/\t+/)[1] =~ /Yes/
              @experiment.dna=1           
            else
              @experiment.dna=0           
            end
            #                       
          when line.match(/^PROTEIN/)
            #
            if line.split(/\t+/)[1] =~ /Yes/
              @experiment.protein=1           
            else
              @experiment.protein=0           
            end
            #            
          when line.match(/^MEMBRANE/)
            #
            if line.split(/\t+/)[1] =~ /Yes/
              @experiment.membrane=1           
            else
              @experiment.membrane=0           
            end
            #            
          when line.match(/^NANOPARTICLE/)
            #
            if line.split(/\t+/)[1] =~ /Yes/
              @experiment.nanoparticle=1           
            else
              @experiment.nanoparticle=0           
            end
            #
          when line.match(/^Io/) && !(line.match(/Io_MOLECULAR_WEIGHT/))                                   
            @experiment.io=line.split(/\t+/)[1]
          when line.match(/SIG_Io/)
            @experiment.sig_Io=line.split(/\t+/)[1] 
          when line.match(/Io_MOLECULAR_WEIGHT/)
            @experiment.io_molecular_weight=line.split(/\t+/)[1]           
          when line.match(/DMAX/)
            @experiment.dmax=line.split(/\t+/)[1]
          when line.match(/^RG/) && !(line.match(/RG_REAL/))
            @experiment.rg=line.split(/\t+/)[1]
          when line.match(/^SIG_RG/) && !(line.match(/SIG_RG_REAL/))                                              
            @experiment.sig_Rg=line.split(/\t+/)[1]        
          when line.match(/^RG_REAL/)  && !(line.match(/SIG_RG_REAL/))                                                 
            @experiment.rg_real=line.split(/\t+/)[1]
          when line.match(/SIG_RG_REAL/) 
            @experiment.sig_Rg_real=line.split(/\t+/)[1]
          when line.match(/V_POROD/)
            @experiment.v_porod=line.split(/\t+/)[1]
          when line.match(/V_C/)
            @experiment.volume_of_correlation=line.split(/\t+/)[1]
          when line.match(/POROD_EXP/)
            @experiment.porod_exponent=line.split(/\t+/)[1]
          when line.match(/^AUTHOR/)    
            # Can have multiple authors, build association with each encounter in the summary.txt file
            #
            nameline = line.split(/[\t]+/)
            @experiment.authors.build(:lastname => nameline[1], :initials => nameline[2]) 

          when line.match(/^iofq_data_file/)          # Intensity data file (use a concatenated name list)
            @experiment.iofq_file_name  = line.chomp.split(/originals\//)[1]                              
          when line.match(/^pofr_data_file/)          # Pair-distance distribution file
            @experiment.pofr_file_name  = line.chomp.split(/originals\//)[1]                       
        end       
      end     
      
      
      genes = data_lines.select{|v| v =~ /^INFO_[0-9]+/}
      genes.each do |line|
         #
         # Build a new gene object
         #
           @temp = Expgene.new()
           index = data_lines.index(line)
           max = index + 5
           while index < max 
             case 
             when data_lines[index] =~ Regexp.new("INFO_[0-9]+")      
         	      @temp.gene_count = data_lines[index].chomp.split(/\_/)[1]
             when data_lines[index] =~ Regexp.new("ABBR_NAME")  
                @temp.abbr_name = data_lines[index].chomp.split(/\t+/)[1]
             when data_lines[index] =~ Regexp.new("EXP_MW")   
                @temp.exp_mw = data_lines[index].chomp.split(/\t+/)[1]               
             when data_lines[index] =~ Regexp.new("ANNOTATION")
                @temp.annotation = data_lines[index].chomp.split(/\t+/)[1]     
             when data_lines[index] =~ Regexp.new("EXP_SEQUENCE")   
                @temp.experimental_sequence = data_lines[index].chomp.split(/[\t]+/)[1]                                  
             end
             index += 1
          end
          @experiment.expgenes.build(:gene_count => @temp.gene_count, :abbr_name => @temp.abbr_name, :exp_mw => @temp.exp_mw, :annotation => @temp.annotation, :experimental_sequence => @temp.experimental_sequence)

      end # end of data_lines
       #
       # Build associated models
       #      
       dammin_test = data_lines.select{|v| v =~ Regexp.new("#REMARK DAMMIN")}
       if dammin_test.size == 1
          index = data_lines.index(dammin_test[0])
          @experiment.build_dammin_result          
          max = index + 5
          while index < max
            case 
            when data_lines[index] =~ Regexp.new("^SPACEGROUP")   
               @experiment.dammin_result.spacegroup = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^NSD")   
               @experiment.dammin_result.nsd = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^STDEV_NSD")   
               @experiment.dammin_result.sig_NSD = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^AVERAGE_OF")   
               @experiment.dammin_result.number_in_average = data_lines[index].chomp.split(/\t+/)[1]                
            end
            index += 1
          end            
       end

       gasbor_test = data_lines.select{|v| v =~ Regexp.new("#REMARK GASBOR")}
       if gasbor_test.size == 1
          index = data_lines.index(gasbor_test[0])
          @experiment.gasbor_results.build()          
          max = index + 6
          while index < max
            case 
            when data_lines[index] =~ Regexp.new("^SPACEGROUP")   
               @experiment.gasbor_results[0].spacegroup = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^NSD")   
               @experiment.gasbor_results[0].nsd = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^STDEV_NSD")   
               @experiment.gasbor_results[0].sig_NSD = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^AVERAGE_OF")   
               @experiment.gasbor_results[0].number_in_average = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^CHI_SQUARE")   
               @experiment.gasbor_results[0].chi_square = data_lines[index].chomp.split(/\t+/)[1]                
            end
            index += 1
          end            
       end

       structural_test = data_lines.select{|v| v =~ Regexp.new("#REMARK STRUCTURAL MODEL")}
       if structural_test.size == 1
          index = data_lines.index(structural_test[0])
          @experiment.build_structural_model          
          max = index + 4
          while index < max
            case 
            when data_lines[index] =~ Regexp.new("^CHI_SQUARE")   
               @experiment.structural_model.chi_square = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^FIT_FILENAME")   
               @experiment.structural_model.fit_filename = data_lines[index].chomp.split(/\t+/)[1]                
             when data_lines[index] =~ Regexp.new("^DESCRIPTION")   
               @experiment.structural_model.description = data_lines[index].chomp.split(/\t+/)[1]                
            end
            index += 1
          end            
       end

       ensemble_test = data_lines.select{|v| v =~ Regexp.new("#REMARK ENSEMBLE MODEL")}
       if ensemble_test.size == 1
          index = data_lines.index(ensemble_test[0])
          @experiment.build_ensemble
          max = index + 11
          while index < max
            case 
            when data_lines[index] =~ Regexp.new("^SCORING_FUNCTION")   
               @experiment.ensemble.scoring_function = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^SCORE")   
               @experiment.ensemble.score = data_lines[index].chomp.split(/\t+/)[1]                
             when data_lines[index] =~ Regexp.new("^SELECTION_METHOD")   
                @experiment.ensemble.selection_method = data_lines[index].chomp.split(/\t+/)[1]
            when data_lines[index] =~ Regexp.new("^SIMULATION_METHOD")   
               @experiment.ensemble.simulation_method = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^SIMULATION_ALGORITHM")   
               @experiment.ensemble.simulation_algorithm = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^SCORE")   
               @experiment.ensemble.score = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^FIT_FILENAME")   
               @experiment.ensemble.fit_filename = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^ENSEMBLE_SIZE")   
               @experiment.ensemble.ensemble_size = data_lines[index].chomp.split(/\t+/)[1]                
            when data_lines[index] =~ Regexp.new("^MEMBER_SIZE")   
               @experiment.ensemble.member_size = data_lines[index].chomp.split(/\t+/)[1]                
             when data_lines[index] =~ Regexp.new("^DIAGNOSTIC_LEGEND")   
               @experiment.ensemble.figure_legend = data_lines[index].chomp.split(/\t+/)[1]                
            end
            index += 1
          end            
       end

       nomodel_test = data_lines.select{|v| v =~ Regexp.new("#REMARK NO MODEL")}
       if nomodel_test.size == 1
          index = data_lines.index(nomodel_test[0])
          @experiment.build_no_model
          max = index + 2
          while index < max
            case 
            when data_lines[index] =~ Regexp.new("^DESCRIPTION")   
               @experiment.no_model.description = data_lines[index].chomp.split(/\t+/)[1]                
            end
            index += 1
          end            
       end


      data_lines.each do |line|
        #
        # RENAMED FILES
        # Must be executed after models are associated with the experiment
        #
        case

        when line.match(/^single_dammin_model/)     # DAMMIN/F single model *.pdb
           @experiment.dammin_result.single_model_filename = line.chomp.split(/dammin\//)[1]                              
        when line.match(/^average_dammin_model/)    # DAMMIN/F averaged model *.pdb
           @experiment.dammin_result.average_model_filename = line.chomp.split(/dammin\//)[1]                                        
        when line.match(/^hires_dammin_model/)      # DAMMIN/F aligned model *.pdb
           @experiment.dammin_result.subcomb_model = line.chomp.split(/dammin\//)[1]                              
        when line.match(/^single_gasbor_model/)     # GASBOR single model *.pdb
           @experiment.gasbor_results[0].single_model_filename = line.chomp.split(/gasbor\//)[1]                              
        when line.match(/^average_gasbor_model/)    # GASBOR averaged model *.pdb
           @experiment.gasbor_results[0].average_model_filename = line.chomp.split(/gasbor\//)[1]                    
        when line.match(/^hires_gasbor_model/)      # GASBOR aligned model *.pdb
           @experiment.gasbor_results[0].subcomb_model = line.chomp.split(/gasbor\//)[1]          
        when line.match(/^pdb_model/)               # STRUCTURE MODEL *.pdb
           @experiment.structural_model.pdb_filename = line.chomp.split(/structure\//)[1]          
        when line.match(/^fitted_SAXS_with_model/)  # STRUCTURE MODELFIT FILE *.dat or *.fit
           @experiment.structural_model.fit_filename = line.chomp.split(/structure\//)[1]
        when line.match(/^ensemble_fit/)            # ENSEMBLE fit file *.dat
           @experiment.ensemble.fit_filename = line.chomp.split(/originals\//)[1]
        when line.match(/^pdb_filename_/)     # ENSEMBLE diagnostic file *.txt
           @experiment.ensemble.pdbfiles = line.chomp.split(/originals\//)[1]   
        when line.match(/no_model_image_/)           # NoModel image file          
           @experiment.no_model.figure_file_name = line.chomp.split(/originals\//)[1]
        end
      
     end 
    return @experiment      
    end #end of method definition

end