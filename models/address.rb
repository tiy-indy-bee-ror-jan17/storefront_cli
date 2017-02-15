class Address < ActiveRecord::Base

  belongs_to :user


  def address_to_string_no_zip
    a = Address.new
    address = "#{a.street}, #{city}, #{state}"
    return address
  end

end
