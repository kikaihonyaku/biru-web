module ApplicationHelper
  
  # CSV出力用  
  def button_to_csv(options = {})
    
    button_to_function "Export CSV", "alert(reloadWithFormat('csv'));", options
  end
  
end
