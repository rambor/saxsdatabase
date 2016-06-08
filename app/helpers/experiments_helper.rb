module ExperimentsHelper
    def salt_list(type)

      if type.to_s == "monovalent"
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
  #      list ="<%= select (\"experiment\", \"salt\", @salt.each_pair {|key, value| puts "#{key} #{value}"}, {:selected => @salt["NaCl"]}) %>  "
#        list = select("experiment", "salt", @salt.each_pair {|key, value| puts "#{key} #{value}"}, {:selected => @salt["NaCl"]})
        list = @salt
      elsif type.to_s == "divalent"

        @divalent = {
        "none" => "none",
        "MgCl2" => "MgCl2",
        "MnCl2" => "MnCl2",
        "CaCl2" => "CaCl2",
        "ZnCl2" => "ZnCl2"                      
        }
#        list = select("experiment", "divalent", @divalent.each_pair {|key, value| puts "#{key} #{value}"}, {:selected => @divalent["none"]}) 
        list = @divalent
      end
    return list
    end
end
