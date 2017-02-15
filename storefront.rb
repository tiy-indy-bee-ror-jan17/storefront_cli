require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require_relative 'models/address'
require_relative 'models/item'
require_relative 'models/order'
require_relative 'models/user'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)

# Your code here

puts "How many users are there?"
puts User.count
puts "\n"

puts "What are the 5 most expensive items?"
Item.order(price: :desc).limit(5).each do |title|
  puts title.title
end
puts "\n"

puts "What's the cheapest book?"
Item.order(price: :asc).limit(1).each do |cheap|
  puts cheap.title
end
puts "\n"

puts "Who lives at '6439 Zetta Hills, Willmouth, WY'? Do they have another address?"
Address.first_name.last_name

# Correct Virginie Mitchell's address to "New York, NY, 10108".
# How much would it cost to buy one of each tool?
# How many total items did we sell?
# How much was spent on books?
# Adventurer Mode
#
# Simulate buying an item by inserting a User from command line input (ask the user for their information) and an Order for that User (have them pick what they'd like to order and other needed order information).
# What item was ordered most often? Grossed the most money?
# What user spent the most?
# What were the top 3 highest grossing categories?
# Epic Mode
#
# Create a new table and model to store reviews of items in the sqlite3 console.
# The reviews table should contain an item_id, a user_id, an integer value from 1-5 that gives the star rating, and text that contains the review.
# Create a command line interface that allows a user to find themselves by email address, pick an item they've ordered and leave a review on it.
# Legendary Mode
#
# Write tests for each of your models and each of the methods that answer the above questions.
