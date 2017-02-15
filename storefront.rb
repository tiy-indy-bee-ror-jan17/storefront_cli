require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require 'pry'
require_relative 'models/user'
require_relative 'models/address'
require_relative 'models/item'
require_relative 'models/order'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)

# Your code here
prompt = TTY::Prompt.new

# How many users are there?
puts User.count
print "\n"
# What are the 5 most expensive items?
Item.order(price: :desc).limit(5).each do |i|
  puts "#{i.title}:$#{i.price}"
end
print "\n"
# What's the cheapest book?
puts Item.where("category LIKE '%Books%'").order(:price).first.title

# Who lives at "6439 Zetta Hills, Willmouth, WY"?
lives_here = Address.find_by(street: "6439 Zetta Hills").user
puts lives_here.first_name
print "\n"
#Do they have another address?
lives_here.addresses.where.not(street: "6439 Zetta Hills").each do |add|
  puts add.street
  puts "#{add.city} #{add.state}, #{add.zip}"
end
print "\n"
# Correct Virginie Mitchell's address to "New York, NY, 10108".
virginie = User.find_by(first_name: "Virginie", last_name: "Mitchell")
virginie.addresses.find_by(state: "NY").update(city: "New York", state: "NY", zip: "10108")
v_address = virginie.addresses.find_by(state: "NY")
puts v_address.street
puts "#{v_address.city} #{v_address.state}, #{v_address.zip}"
print "\n"
# How much would it cost to buy one of each tool?
puts "$#{Item.where("category LIKE '%tools%'").sum(:price)}"
print "\n"
# How many total items did we sell?
puts "#{Order.sum(:quantity)} items"
print "\n"
# How much was spent on books?
list = Item.joins(:orders).where("category LIKE '%Books%'").sum("price * quantity")
puts "$#{list} spent on books"

##################
#Adventure MODE
##################

# Simulate buying an item by inserting a User from command line input (ask the user for their information) and an Order for that User (have them pick what they'd like to order and other needed order information).
if prompt.yes?("would you like buy something?")
  user_firstname = prompt.ask("Enter your first name: ")
  user_lastname = prompt.ask("Enter your first name: ")
  user_email = prompt.ask("Enter your email: ")

  item_ordered = prompt.select("choose an item to buy", Item.order(:price).group_by{|i| i[:title]})[0]

  quantity_ordered = prompt.ask("Enter how many of that item you want: ").to_i

  newuser = User.create(first_name: user_firstname, last_name: user_lastname, email: user_email)

  Order.create(user_id: newuser.id, item_id: item_ordered.id, quantity: quantity_ordered)
  puts "Thank you, order complete!"
end

# What item was ordered most often?
#Order.group(:item_id).sum(:quantity)
#binding.pry

#Grossed the most money?

# What user spent the most?


# What were the top 3 highest grossing categories?
