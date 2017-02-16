class User < ActiveRecord::Base

  has_many :addresses
  has_many :orders
  has_many :reviews
end
