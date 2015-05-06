module ApplicationHelper
  
  # CSV出力用  
  def button_to_csv(options = {})
    
    button_to_function "Export CSV", "alert(reloadWithFormat('csv'));", options
  end
  
  # 増減を表示します
  def fluctuate_disp(fluctuate)

    if fluctuate.blank?
      "0"
    else
      result = ""
      if fluctuate > 0 
        result = "+"
      elsif fluctuate < 0
        result = ""
      else
        result = ""
      end

      result += fluctuate.to_s
      
    end
    
    
  end

end
