require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require_relative 'models/user'
require_relative 'models/order'
require_relative 'models/address'
require_relative 'models/item'


ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)

# Your code here
puts User.count

Item.order(price: :desc).limit(5).each do |item|
                                          puts item.title
                                        end

puts Item.where("category LIKE '%books%'").order(price: :asc).first.title

person = Address.find_by(street: "6439 Zetta Hills").user
  puts "#{person.first_name} #{person.last_name} #{person.id}"

Address.where(user_id: 40).each do |add|
                                  puts "#{add.street} #{add.city} #{add.state}"
                                end

# vm = User.find_by(first_name: "Virginie", last_name: "Mitchell").id

vm = User.find_by(first_name: "Virginie", last_name: "Mitchell").addresses.find_by(state: "NY")
vm.update(city: "New York", state: "NY", zip: 10108)
puts "Virginie's address has been updated to #{vm.street} #{vm.city}, #{vm.state}, #{vm.zip}"

puts Item.where("category LIKE '%tool%'").sum(:price)

puts Order.sum(:quantity)

price_table = Order.joins(:item)
puts price_table.where("category LIKE '%books%'").sum("price * quantity")
