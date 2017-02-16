#!/usr/bin/env ruby
require 'pry'
require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require_relative 'models/user'
require_relative 'models/order'
require_relative 'models/item'
require_relative 'models/address'
# require_relative 'password'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)

#EXPLORER MODE
puts "※ User count?: \n\t#{User.count}"

puts "※ Top 5 highest-priced items:"
Item.order(price: :desc).take(5).each do |item|
  puts "\t" + item.title + " ($#{item.price})"
end

puts "※ What's the cheapest book?:"
puts "\t" + Item.where('category LIKE ?', '%book%').order(:price).take.title
#SELECT title FROM items WHERE category LIKE "%Book%" ORDER BY price ASC LIMIT 1;

puts "※ Who lives at \"6439 Zetta Hills, Willmouth, WY\"? Do they have another address?"
zetta_user = Address.find_by("street == '6439 Zetta Hills' AND city == 'Willmouth' AND state == 'WY'").user
puts "\t#{zetta_user.first_name} #{zetta_user.last_name}"
zetta_user_id = Address.find_by("street == '6439 Zetta Hills' AND city == 'Willmouth' AND state == 'WY'").id
zetta_other_address = Address.where(user: zetta_user_id).take
puts "\t#{zetta_other_address.street}, #{zetta_other_address.city}, #{zetta_other_address.state}"

puts "※ Correct Virginie Mitchell's address to \"New York, NY, 10108\":"
user_mitchell = User.find_by(first_name: 'Virginie', last_name: 'Mitchell')
address_mitchell = user_mitchell.addresses.find_by(state: 'NY')
address_mitchell.update(city: 'New York', zip: '10108')
puts "\t#{address_mitchell.street}, #{address_mitchell.city}, #{address_mitchell.state}, #{address_mitchell.zip}"

puts "※ How much would it cost to buy one of each tool?"
puts "\t$" + Item.where('category LIKE ?', '%tool%').sum('price').to_s

puts "※ How many total items did we sell?"
puts "\t" + Order.sum('quantity').to_s

puts "※ How much was spent on books?"
puts "\t$" + Item.joins(:orders).where('category LIKE ?','%book%').sum('price * quantity').to_s

pry
