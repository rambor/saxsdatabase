class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def createKratky(filename, qmax)
    tempArray = Array.new
    myDataArray = Array.new
    nextFile = Array.new    
    x =[]
    y =[]
    
    open(filename){|f| tempArray = f.readlines}
    count = 0
    tempArray.each do |line|
      # split the line
      values = line.lstrip.split(/[\t\s]+/)

#      if (values[0] =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/i) && (values[1] =~ /([0-9].[0-9]+E[\+-][0-9]+)|([0-9]+.[0-9]+)/i)
      if (check_single(values[0]) && check_single(values[1]))            
         q = values[0].to_f
         x << q
         y << (q*q*values[1].to_f)
         count += 1
       elsif ((values[0] == "#") && (count > 10))  
         nextFile << count
         count += 1         
       end
      
    end
    xconst = 345/qmax
    y_max=y.max
    ymax = y_max*0.05 + y_max            
    yconst = 260/ymax    
    
    x.each_index do |ele|
         if !nextFile.index(ele).nil?
             myDataArray << "{x:102872, y:102872, z:102872}"
         else 
             myDataArray << "{x:#{x[ele]*xconst + 30}, y:#{(y[ele] - ymax)*-yconst} }"            
         end               
    end
    
    return myDataArray
    
  end
  
  def createThumbJSON(filename)
    tempArray = Array.new
    myDataArray = Array.new
    qmax = 0.0
    nextFile = Array.new
    #
    # Open summary.txt and read in for filling in form
    #
    x =[]
    y =[]
    z =[]
    
    open(filename){|f| tempArray = f.readlines}

    count = 0
    tempArray.each do |line|
      # split the line
      values = line.lstrip.split(/[(\t\s)]+/)
      
      if (check_single(values[0]) && check_single(values[1]) && values[1].to_f > 0)            
         x << values[0].to_f
         y << Math.log(values[1].to_f)
         z << Math.log(values[2].to_f) 
         count += 1         
      elsif ((values[0] == "#") && (count > 10))  
         nextFile << count
         count += 1         
      end

    end    

    qmax = x.last
    xconst = 148/qmax
    y_max=y.max
    ymax=0.0    

    yexp = Math.exp(y_max)
    ymax = Math.log(yexp*0.9 + yexp)

    yexp = Math.exp(y.min)
    ymin = Math.log(yexp - 0.3*yexp)
    
    yconst = 150/(ymin - ymax)
    stop = x.size
    
    x.each_index do |ele|
         if !nextFile.index(ele).nil?
             myDataArray << "{x:102872, y:102872, z:102872}"
         else 
             if (Random.rand(10) < 4)
               myDataArray << "{x:#{x[ele]*xconst}, y:#{(y[ele] - ymax)*yconst}, z:#{(z[ele]-ymax)*yconst}}"            
             end
         end                  
    end    

    return myDataArray
  end
  
  def loadFileIntoJSON(filename, logStatus)
    tempArray = Array.new
    myDataArray = Array.new
    qmax = 0.0
    nextFile = Array.new
    #
    # Open summary.txt and read in for filling in form
    #
    x =[]
    y =[]
    z =[]

    open(filename){|f| tempArray = f.readlines}
    count = 0
    tempArray.each do |line|
      # split the line
      values = line.lstrip.split(/[(\t\s)]+/)
            
      if (check_single(values[0]) && check_single(values[1]))    
         x << values[0].to_f
         if (logStatus && values[1].to_f > 0)
           y << Math.log(values[1].to_f)
           z << Math.log(values[2].to_f) 
         else
           y << (values[1].to_f)
           z << 0         
         end
         count += 1         
      elsif ((values[0] == "#") && (count > 10))  
         nextFile << count
         count += 1         
      end

    end    

    qmax = x.last
    xconst = 345/qmax
    y_max=y.max
    ymax=0.0    
    
    if (logStatus) 
      yexp = Math.exp(y_max)
      ymax = Math.log(yexp*0.9 + yexp)
    else
      ymax = y_max*0.1 + y_max
    end
    
    ymin = (logStatus) ? y.min : 0
    if (logStatus)
      yconst = 260/(ymin - ymax)
    else
      yconst = 270/(ymin - ymax)
    end
    stop = x.size
    
    x.each_index do |ele|
         if !nextFile.index(ele).nil?
             myDataArray << "{x:102872, y:102872, z:102872}"
         else 
             myDataArray << "{x:#{x[ele]*xconst + 30}, y:#{(y[ele] - ymax)*yconst}, z:#{(z[ele]-ymax)*yconst}}"            
         end                  
    end    

    return myDataArray, qmax
  end  
  
  private 
  def check_single(value)
    if value =~ /([0-9].[0-9]+E[\+-]*[0-9]+)|([0-9]+.[0-9]+)/i
      return true
    end
    return false
  end
end
