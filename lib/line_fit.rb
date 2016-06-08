module LineFit
  def auto_fit(x_data, y_data, w_data)
    @x_data = x_data
    @y_data = y_data
    @w_data = w_data
    @x_range = Array.new
    @y_range = Array.new
    @w_range = Array.new
    qmax = @x_data[@x_data.size - 1]
    vx = GSL::Vector.alloc(@x_data)
    vy = GSL::Vector.alloc(@y_data)
    vw = GSL::Vector.alloc(@w_data)
    c0, c1, cov00, cov01, cov11, chisq = GSL::Fit::linear(vx,vy)  
    #
    # intercept - c0
    # slope - c1
    #
    @x_range = @x_data
    @y_range = @y_data
    @w_range = @w_data
    #
    index = @x_data.size - 2    
    #
     puts "Intercept: #{c0}, Slope: #{c1} size: #{@x_data.size}\n"
    #
    residuals = (@y_data.to_gv - c1*@x_data.to_gv).add_constant(-c0).square      
    min_residual = residuals.sort.median_from_sorted_data
    #
    # Random subsample fitting
    #
    # Given the entire dataset, grab random subsamples ranging from 2 to max(X_array data)
    #
    # Repeat 3000 times?
    #
    trial = 0
    r = GSL::Rng.alloc()  
    z = GSL::Rng.alloc()  
    puts "#\n\t STARING LMS SAMPLING:\n#\n"
    until trial > 3000
     #
     # Pick a random number between 2 and (max_data_size - 1)
     #
     subsample = r.uniform_int(@x_range.size)
     
     rand_order = z.uniform
     until subsample >= 3
       subsample = r.uniform_int(@x_range.size)
     end
     #
     # Now grab a random subsample set of data points from the input array @x_range
     #
     # Grab random selection of elements from the array, random order, then select the subsample space
     #
     random_index = rand_n(subsample,@x_range.size)
     #
     # Now sort the array in order
     #
     x_random = Array.new
     y_random = Array.new
     w_random = Array.new
     random_index.each do |x|
       x_random << @x_range[x]
       y_random << @y_range[x]
       w_random << @w_range[x]
     end
     #
     # Do the wlinear and calculate the residuals
     #     
     vx = GSL::Vector.alloc(x_random)
     vy = GSL::Vector.alloc(y_random)
     vw = GSL::Vector.alloc(w_random)
     c0, c1, cov, chisq = GSL::Fit::linear(vx,vy)
     #
     # Convert to Vector Math (speed gain)
     #
     residuals = (@y_range.to_gv - c1*@x_range.to_gv).add_constant(-c0).square     
     median_test = residuals.sort.median_from_sorted_data
     #
     #
     #
     if median_test < min_residual
       min_residual = median_test
       @x_keep = vx.to_na 
       @y_keep = vy.to_na
       @w_keep = vw.to_na
       @slope = c1
       @intercept = c0
       #puts "Min: #{min_residual} m: #{@slope} b: #{@intercept}"
     end
     #
     #
     #
     trial += 1
    end
    parameters = Hash.new
    @x_range
    @y_range
    @w_range
    parameters['slope'] = @slope
    parameters['intercept'] = @intercept
    return parameters
    @s_o = 1.4826*(1.0 + 5.0/(@x_range.size - 2.0))*Math.sqrt(min_residual)
  end
  private
  def rand_n(n, max)
      randoms = Set.new
      loop do
          randoms << rand(max)
          return randoms.to_a if randoms.size > n
      end
  end
end
