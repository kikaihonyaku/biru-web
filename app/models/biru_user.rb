class BiruUser < ActiveRecord::Base
  attr_accessible :code, :name, :password
  
  def self.authenticate(code, password)
    where(:code=> code,
      :password => password).first
      #:password => Digest::SHA1.hexdigest(password)).first
  end
    
end
