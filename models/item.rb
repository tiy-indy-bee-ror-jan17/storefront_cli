class Item < ActiveRecord::Base

  has_many :orders
  has_many :reviews
end
