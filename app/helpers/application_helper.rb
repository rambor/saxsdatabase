module ApplicationHelper
    def head_extras
    end

    def map_location
      production_file = '/users/home/rambor/etc/bioisis.yml'
      map_key = "ABQIAAAA8Lqf8UMkzace2ylJKSMp2BTJQa0g3IQ9GZqIMmInSLzwtGDKaBRvERqLmSLbNjlI0xRpedEaKfoEHA" #localhost mapkey
      if File.exists? production_file
        map_key = "ABQIAAAA8Lqf8UMkzace2ylJKSMp2BQtjLRuT52HaHEczY4Ga0HmhyPS1hS5Ds5JoD05Rfgr2fudzuiOG9q3uQ" #bioisis.net mapkey
      end
      return map_key
    end

    def truncate_words(text, length = 8, end_string = ' ...')
      words = text.split()
      words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
    end

    def submit_tag(value = "Save Changes"[], options={} )
      or_option = options.delete(:or) #remove the array element corresponding to :or and re-assigning the array as or_optio
      return super + "<span class='button_or'>"+" or"+" " + or_option + "</span>" if or_option
      super
    end

    def ajax_spinner_for(id, spinner="spinner.gif")
      "<img src='/images/#{spinner}' style='display:none; vertical-align:middle;' id='#{id.to_s}_spinner'> "
    end

    def avatar_for(user, size=32)
      image_tag "http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.md5(user.email)}&rating=PG&size=#{size}", :size => "#{size}x#{size}", :class => 'photo'
    end

    def feed_icon_tag(title, url)
      (@feed_icons ||= []) << { :url => url, :title => title }
      link_to image_tag('feed-icon.png', :size => '14x14', :alt => "Subscribe to #{title}"), url
    end

    def search_posts_title
      returning(params[:q].blank? ? 'Recent Posts' : "Searching for" + " '#{h params[:q]}'") do |title|
  #      title << " "+'by {user}'[:by_user,h(User.find(params[:user_id]).display_name)] if params[:user_id]
        title << " "+"by #{h(User.find(params[:user_id]).display_name)}" if params[:user_id]
  #      title << " "+'in {forum}'[:in_forum,h(Forum.find(params[:forum_id]).name)] if params[:forum_id]      
        title << " "+"in #{h(Forum.find(params[:forum_id]).name)}" if params[:forum_id]
      end
    end

    def topic_title_link(topic, options)
      if topic.title =~ /^\[([^\]]{1,15})\]((\s+)\w+.*)/
        "<span class='flag'>#{$1}</span>" + 
        link_to(h($2.strip), topic_path(@forum, topic), options)
      else
        link_to(h(topic.title), topic_path(@forum, topic), options)
      end
    end

    def search_posts_path(rss = false)
      options = params[:q].blank? ? {} : {:q => params[:q]}
      prefix = rss ? 'formatted_' : ''
      options[:format] = 'rss' if rss
      [[:user, :user_id], [:forum, :forum_id]].each do |(route_key, param_key)|
        return send("#{prefix}#{route_key}_posts_path", options.update(param_key => params[param_key])) if params[param_key]
      end
      options[:q] ? search_all_posts_path(options) : send("#{prefix}all_posts_path", options)
    end

    # on windows and this isn't working like you expect?
    # check: http://beast.caboo.se/forums/1/topics/657
    # strftime on windows doesn't seem to support %e and you'll need to 
    # use the less cool %d in the strftime line below
    def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      distance_in_minutes = (((to_time - from_time).abs)/60).round

      case distance_in_minutes
        when 0..1           then (distance_in_minutes==0) ? 'a few seconds ago' : '1 minute ago'
        when 2..59          then "#{distance_in_minutes} minutes ago"
        when 60..90         then "1 hour ago"
        when 90..1440       then "#{(distance_in_minutes.to_f/60.0).round} hours ago"
        when 1440..2160     then '1 day ago' # 1 day to 1.5 days
        when 2160..2880     then "#{(distance_in_minutes.to_f / 1440.0).round} days ago" # 1.5 days to 2 days
        else from_time.strftime("%b %e, %Y  %l:%M%p").gsub(/([AP]M)/) { |x| x.downcase }
      end
    end

    def pagination collection
      if collection.page_count > 1
        "<p class='pages'>" + 'Pages' + ": <strong>" + 
        will_paginate(collection, :inner_window => 10, :next_label => "next", :prev_label => "previous") +
        "</strong></p>"
      end
    end

    def next_page collection
      unless collection.current_page == collection.page_count or collection.page_count == 0
        "<p style='float:right;'>" + link_to("Next page", { :page => collection.current_page.next }.merge(params.reject{|k,v| k=="page"})) + "</p>"
      end
    end

    def nice_date(date)
      h date.strftime("%d %B %Y")
    end

    def nice_date_time(date)
      h date.strftime("%A %d %B %Y - %H:%M %p")
    end

    def calculate_mw(sequence)
  #   amino_acids = {"A" => 89.1, "G" => 75.1, "I" => 131.2, "L" => 131.2, "V" => 117.1, "P" => 115.1, "K" => 146.2, "Q" => 146.1, "R" => 174.2, "N" => 132.1, "E" => 147.1, "C" =>121.1, "M" => 149.2, "F" => 165.2, "Y" => 181.2, "T" => 119.1, "S" => 105.1, "H" => 155.2, "W" => 204.2, "D" => 133.1}
      sequence_array = sequence.upcase.scan(/./)

      histo = sequence_array.inject(Hash.new(0)){|h,x| h[x] += 1;h }

      if histo.size > 4    
        mw = histo["A"].to_i*89.1 + histo["G"]*75.1 + histo["I"]*131.2 + histo["L"]*131.2 + histo["V"]*117.1 + histo["P"]*115.1 + histo["K"]*146.2 + histo["Q"]*146.1 + histo["R"]*174.2 + histo["N"]*132.1 + histo["E"]*147.1 + histo["C"]*121.1 + histo["M"]*149.2 + histo["F"]*165.2 + histo["Y"]*181.2 + histo["T"]*119.1 + histo["S"]*105.1 + histo["H"]*155.2 + histo["W"]*204.2 + histo["D"]*133.1
        mw = mw - (sequence_array.size - 1)*18.01528 #remove the liberated waters  
      elsif ((histo.size <= 4) && (histo["U"].to_i > 1))
        mw = histo["A"].to_i*329.2 + histo["G"].to_i*345.2 + histo["C"].to_i*305.2 + histo["U"].to_i*306.2 + 159 #159 refers to the presence of a 5' triphosphate
      elsif ((histo.size <= 4) && (histo["T"].to_i > 1))
        mw = histo["A"].to_i*313.2 + histo["G"].to_i*329.2 + histo["C"].to_i*289.2 + histo["T"].to_i*304.2 + 79 #79 refers to terminal 5' monophosphate
      end

      return mw
    end

    def link_search(source_id, test_id)

      source_experiment = Experiment.find(source_id)    
      stat = false
       if source_experiment.link_to.size > 0
        
        source_experiment.link_to.each do |link|
          if link.id == test_id
            stat = true
          end
        end
        
       end
       return stat
      
    end

end
