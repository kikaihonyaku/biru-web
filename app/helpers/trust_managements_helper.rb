module TrustManagementsHelper
  
  def sjis_convert(str)
     str.gsub(REPLACE_KEYS, CONVERSIONS)
  end

private
   # Unicode変換組み合わせ
   CONVERSIONS = {
     "\u301c" => "\uff5e", # wave-dash
     "\u2212" => "\uff0d", # full-width minus
     "\u00a2" => "\uffe0", # cent sign
     "\u00a3" => "\uffe1", # pound sign
     "\u00ac" => "\uffe2", # not sign
     "\u2014" => "\u2015", # full-width dash
     "\u2016" => "\u2225"  # double vertical line
   }

   # 変換対象
   REPLACE_KEYS = /[#{CONVERSIONS.keys.join}]/
   
end
