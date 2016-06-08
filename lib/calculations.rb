module Calculations
  def calculate_mw(sequence)
#   amino_acids = {"A" => 89.1, "G" => 75.1, "I" => 131.2, "L" => 131.2, "V" => 117.1, "P" => 115.1, "K" => 146.2, "Q" => 146.1, "R" => 174.2, "N" => 132.1, "E" => 147.1, "C" =>121.1, "M" => 149.2, "F" => 165.2, "Y" => 181.2, "T" => 119.1, "S" => 105.1, "H" => 155.2, "W" => 204.2, "D" => 133.1}
    sequence_array = sequence.upcase.scan(/./)
    
    histo = sequence_array.inject(Hash.new(0)){|h,x| h[x] += 1;h }

    if histo.size > 4    
      mw = histo["A"].to_i*89.1 + histo["G"]*75.1 + histo["I"]*131.2 + histo["L"]*131.2 + histo["V"]*117.1 + histo["P"]*115.1 + histo["K"]*146.2 + histo["Q"]*146.1 + histo["R"]*174.2 + histo["N"]*132.1 + histo["E"]*147.1 + histo["C"]*121.1 + histo["M"]*149.2 + histo["F"]*165.2 + histo["Y"]*181.2 + histo["T"]*119.1 + histo["S"]*105.1 + histo["H"]*155.2 + histo["W"]*204.2 + histo["D"]*133.1
      mw = mw - (sequence_array.size - 1)*18.01528 #remove the liberated waters  
    elsif ((histo.size <= 4) && (histo["U"].to_i > 1)) && !(histo["T"].to_i > 1)
      mw = histo["A"].to_i*329.2 + histo["G"].to_i*345.2 + histo["C"].to_i*305.2 + histo["U"].to_i*306.2 + 159 #159 refers to the presence of a 5' triphosphate
    elsif ((histo.size <= 4) && (histo["T"].to_i > 1)) && !(histo["U"].to_i > 1)
      mw = histo["A"].to_i*313.2 + histo["G"].to_i*329.2 + histo["C"].to_i*289.2 + histo["T"].to_i*304.2 + 79 #79 refers to terminal 5' monophosphate
    else
      mw = histo["A"].to_i*(313.2+329.2)*0.5 + histo["G"].to_i*(329.2+345.2)*0.5 + histo["C"].to_i*(289.2+305.2)*0.5 + histo["T"].to_i*304.2 + histo["U"].to_i*306.2+ 79
    end
        
    return mw
  end
  
  
end