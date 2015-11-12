# -*- coding:utf-8 -*-

require 'net/http'
require 'open-uri' # open関数でurlを読み込む為に必要
require 'json'


require 'base64'
require 'uri'
require 'hmac'
require 'hmac-sha1'

namespace :biruweb do
  task :trust_attack_geocode => :environment do
    
    # 登録されているアタックリスト物件の住所情報を逆geocodeして郵便番号を取得
    # 重点実施地郵便番号マスタから、その印付けを行う。
    
    # 対象の物件情報を取得
    Building.scoped.where("attack_code is not null" ).each do | building |
    
      if building.gmaps
        unless building.postcode
          
          url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{building.latitude.to_s},#{building.longitude.to_s}&sensor=false&client=gme-chuobuildingkanri"
          a = signURL("ms4rVf_yzC5Ejdn4qJqyHoLMVRY=", url).chomp.to_s
          uri = URI.parse(a)
        
    	    json = open(uri).read
          
          p building.name
          result = JSON.parse(json)
          if result["status"] == "OK"
            
            result["results"][0]["address_components"].each do |arr|
              if arr["types"][0] == "postal_code"
                p arr["long_name"] + " " + building.address + " " + building.name
                
                # 物件情報に対し、逆geocodeして郵便番号を設定
                building.postcode = arr["long_name"]
                
                # 設定した郵便番号が重点実施郵便番号であれば、重点実施フラグを設定する（そうでなければそのフラグを外す）
                # TODO
                
                building.save!
                
                break
              end
            end
            
            
          else
            p "NG"
          end
          
          
        end
      end
    end
    
  end
  
  
  # 2014/08/17 takashi add
  def urlSafeBase64Decode(base64String)
    return Base64.decode64(base64String.tr('-_','+/'))
  end

  # 2014/08/17 takashi add
  def urlSafeBase64Encode(raw)
    return Base64.encode64(raw).tr('+/','-_')
  end

  # 2014/08/17 takashi add
  def signURL(key, url)
    parsedURL = URI.parse(url)
    urlToSign = parsedURL.path + '?' + parsedURL.query

    # Decode the private key
    rawKey = urlSafeBase64Decode(key)

    # create a signature using the private key and the URL
    sha1 = HMAC::SHA1.new(rawKey)
    sha1 << urlToSign
    rawSignature = sha1.digest()

    # encode the signature into base64 for url use form.
    signature =  urlSafeBase64Encode(rawSignature)

    # prepend the server and append the signature.
    signedUrl = parsedURL.scheme+"://"+ parsedURL.host + urlToSign + "&signature=#{signature}"
    return signedUrl
  end
    
end