class Order < ActiveRecord::Base
  has_many :customers
end
