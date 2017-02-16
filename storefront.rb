require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require_relative 'models/user'
require_relative 'models/order'
require_relative 'models/item'
require_relative 'models/address'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)

# Explorer Mode

# 1 How many users are there?

puts User.count

# 2 What are the 5 most expensive items?

Item.order(price: :desc).first(5).each do |item|
  puts item.title
end

# 3 What's the cheapest book? (Does that change for "category is exactly 'book'" versus "category contains 'book'"?)
#
item = Item.where(category: "Books").order(price: :asc).first
puts item.title

item = Item.where("category LIKE ?", "%Books%").order(price: :asc).first
puts item.title

# 4 Who lives at "6439 Zetta Hills, Willmouth, WY"? Do they have another address?

user = Address.find_by(street: "6439 Zetta Hills", city: "Willmouth", state: "WY").user
puts "#{user.first_name} #{user.last_name}"

user.addresses.where.not(street: "6439 Zetta Hills", city: "Willmouth", state: "WY").each do |address|
  puts "#{address.street} #{address.city}, #{address.state}"
end

# 5 Correct Virginie Mitchell's address to "New York, NY, 10108".

new_address = User.find_by(first_name: "Virginie", last_name: "Mitchell").addresses.find_by(state: "NY")

new_address.update(city: "New York", state: "NY", zip: 10108)

puts "#{new_address.street} #{new_address.city}, #{new_address.state} #{new_address.zip}"

# 6 How much would it cost to buy one of each tool?

puts Item.where("category LIKE ?", "%Tools%").sum(:price)

# 7 How many total items did we sell?

puts Order.sum(:quantity)

# 8 How much was spent on books?

books_revenue = Order.joins(:item).where("category LIKE ?", "%Books%").sum("price * quantity")

puts books_revenue

# Adventure Mode

# 1 Simulate buying an item by inserting a User from command line input (ask the user for their information) and an Order for that User (have them pick what they'd like to order and other needed order information).

prompt = TTY::Prompt.new

if prompt.yes?("Would you like to add an order?")
  name = prompt.ask("What's your first and last name?")
  email = prompt.ask("What's your email?")
  item = prompt.select("What would you like to order?", ['Ergonomic Granite Chair', 'Small Cotton Hat', 'Incredible Granite Computer'])
  quantity = prompt.ask("How many would you like to order?")

  first_name, last_name = name.split(" ").map(&:capitalize)
  new_user = User.create(first_name: first_name, last_name: last_name, email: email)

  user_id = new_user.id
  item_id = Item.find_by(title: item).id
  new_order = Order.create(user_id: user_id, item_id: item_id, quantity: quantity)
else
  "Goodbye"
end

# 2 What item was ordered most often? Grossed the most money?

order = Order.joins(:item).select("item_id, sum(quantity) AS total").group(:item_id).order("total desc").first

puts "#{order.item.title} was ordered #{order.total} times."

highest_grossing = Order.joins(:item).select("item_id, sum(items.price * orders.quantity) AS total").group(:item_id).order("total desc").first

puts "#{highest_grossing.item.title} grossed: $#{highest_grossing.total}."

# 3 What user spent the most?

user = User.joins(orders: :item).select("user_id, first_name, last_name, sum(items.price * orders.quantity) AS total").group(:user_id).order("total desc").first

puts "#{user.first_name} #{user.last_name} spent $#{user.total}."


# 4 What were the top 3 highest grossing categories?

top_three = Item.joins(:orders).select("category, sum(items.price * orders.quantity) AS total").group(:category).order("total desc").first(3)

top_three.each do |item|
  puts "#{item.category} grossed $#{item.total}"
end
