class SearchController < ApplicationController

    def index
      respond_to do |format| #this is REST web-service support telling the server to respond (respond_to) in one of two formats depending on the request
        format.html
      end
    end

    def gene_view
      @class="gene"
      @results =Array.new
      @results << Gene.find_by_id(params[:id])
      @query= Gene.find(params[:id]).locus_name
      respond_to do |format|
        format.html { render :action =>"search_results" }
      end
    end
    
    def bid_search
      @submission = Submission.find_by_data_directory(params[:id])   
    end

    def search_results
      @query = params[:searchquery]
      @species_list = String.new
      organisms = Organism.find(:all)
      organisms.each do |x|
         @species_list = @species_list+"#{x.abbreviation}|"
      end
      puts "LIST: #{params[:searchquery].match(/#{@species_list}/i).nil?} #{@query}"
      @species_list = "("+ @species_list.chop!+")"+"[0-9]{3,5}"
      #
      # PF0081, SSO1281
      #
      if (!params[:searchquery].match(/view|show|list/i).nil? && !params[:searchquery].match(/#{@species_list}/i).nil?)
        @class= "gene"
        #parse the string to match the locus name with gene id.
        temp_string = params[:searchquery].scan(/\w+/)
        #iterate through the array and match using only the abbreviations describing the organisms
        @results = Array.new
        temp_string.each do |x|
          if Gene.find_by_locus_name(x)
            @results << Gene.find_by_locus_name(x).id
          end
        end
      elsif !params[:searchquery].match(/yannone|smy/i).nil?
        @class="smy"
      else   #if not a locus query, treat as a general search of the index tables.
        @class = "general" #specifiying which partial to display by the class.  
       # klasses = FERRETABLE_MODELS.collect {|klass| Kernel.const_get klass}      
       # @results = klasses.inject([]) {|out,klass| out << klass.find_id_by_contents(params[:searchquery], :limit=>20)}.flatten
      end    
      respond_to do |format|
        format.html
      end    

    end

  end

