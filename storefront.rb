require 'pry'
require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require_relative 'models/user'
require_relative 'models/item'
require_relative 'models/order'


ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)


# puts "The total users count is: #{User.count}"
#
# puts "The 5 most expensive items are #{Item.select(:title).order(:price).last(5)}"
#
# puts "The cheapest book is #{Item.select(:title).order(:price).first(1)}"
#
# puts "#{} lives at 6439 Zetta Hills, Willmouth, WY."

# puts "It would cost #{Item.where("category = ?" Tool).sum(:price)} to buy one of each tool"
#
# puts "We sold #{Order.sum(:quantity)} items"
#
puts "we spent #{Order.sum(Order.select(:quantity)*Item.select(:price)).joins("INNER JOIN items ...> ON items.id = orders.item_id")} on books"
