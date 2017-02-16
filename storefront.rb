require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require_relative 'models/user'
require_relative 'models/item'
require_relative 'models/order'
require_relative 'models/address'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)

debug = true


# How many users are there?
puts "\nNumber of users"
puts User.count

# What are the 5 most expensive items?
puts "\n5 most expensive items"
Item.order(price: :desc).limit(5).each do |item|
  puts item.title
end

# What's the cheapest book?
puts "\nCheapest book"
Item.order(price: :asc).where(category: 'Books').limit(1).each do |item|
  puts item.title
end

# Who lives at "6439 Zetta Hills, Willmouth, WY"?
puts "\nWho lives at '6439 Zetta..' "
Address.where(street: '6439 Zetta Hills').each do |item|
  puts "#{item.user.first_name} #{item.user.last_name}"
# first = item.user.first_name
# last  = item.user.last_name
end

# Do they have another address?
puts "\nDo they have another address?"
# uid = User.where(first_name: first, last_name: last)
Address.where(user_id: 40).each do |address|
  puts address.street
  puts address.city
  puts address.state
end

# Correct Virginie Mitchell's address to "New York, NY, 10108".
puts "\nCorrect Virginie Mitchell\'s address to \'New York, NY, 10108"
uid = User.where(first_name: 'Virginie',last_name: 'Mitchell').first
uid.addresses.update(city: 'New York', state: 'NY', zip: '10108')
uid.addresses.each do |address|
  puts address.street
  puts address.city
  puts address.state
  puts address.zip
end

# How much would it cost to buy one of each tool?
puts "\nHow much would it cost to buy one of each tool?"
price_list = []
Item.where("category LIKE '%tool%'").each do |item|
  # puts "price = #{item.price}" if debug
  price_list << item.price
end
puts "$#{price_list.reduce(:+)}"

# How many total items did we sell?
puts "\nHow many total items did we sell?"
q_array = []
Order.all.each do |order|
  q_array << order.quantity
  # puts order.quantity
end
puts "Total items = #{q_array.reduce(:+)}"

# How much was spent on books?
puts "\nHow much was spent on books?"
puts "$#{Order.joins(:item).where("items.category LIKE '%book%'").sum("items.price * orders.quantity")}"
