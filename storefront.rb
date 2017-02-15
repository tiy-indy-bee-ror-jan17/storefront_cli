require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require 'pry'
require_relative 'models/user/'
require_relative 'models/address/'
require_relative 'models/item/'
require_relative 'models/order/'

# ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)

###### Explorer Mode
# How many users are there?
puts "There are #{User.count} users.\n\n"

# What are the 5 most expensive items?
puts "The five most expensive items are:"
Item.order(price: :desc).limit(5).each do |item|
  puts "#{item.title} costs $#{item.price}"
end
puts "\n"

# What's the cheapest book?
cheap_book = Item.where("category LIKE '%books%'").order(:price).first
puts "#{cheap_book.title} is the cheapest book at $#{cheap_book.price}\n\n"

# Who lives at "6439 Zetta Hills, Willmouth, WY"? Do they have another address?
zeta = Address.find_by(street: "6439 Zetta Hills", city: "Willmouth", state: "WY").user
puts "#{zeta.first_name} #{zeta.last_name} lives at 6439 Zetta Hills, Willmouth, WY."

puts "Corrine Little has two addresses:"
zeta.addresses.each do |x|
  puts "#{x.street}, #{x.city}, #{x.state}"
end
puts "\n"

# Correct Virginie Mitchell's address to "New York, NY, 10108".

virg = User.find_by(first_name: "Virginie", last_name: "Mitchell").addresses.find_by(state: "NY")
virg.update(city: "New York", zip: 10108)
puts "Fixed address to #{virg.street}, #{virg.city}, #{virg.state}, #{virg.zip}"

# How much would it cost to buy one of each tool?
total = Item.where("category LIKE '%tool%'").sum(:price)
puts "Buying one of each tool costs $#{total}."
puts "\n"
# How many total items did we sell?
total_items = Order.sum(:quantity)
puts "We sold #{total_items} items."
puts "\n"
# How much was spent on books?
spent = Item.joins(:orders).where("category LIKE '%books%'").sum("price*quantity")
puts "$#{spent} was spent on books."

######### Adventurer Mode

# Simulate buying an item by inserting a User from command line input (ask the user for their information) and an Order for that User (have them pick what they'd like to order and other needed order information).
prompt = TTY::Prompt.new

if prompt.yes?("Would you like to buy an item?")
  first_name = prompt.ask("What is your first name?")
  last_name = prompt.ask("What is your last name?")
  email = prompt.ask("What is your email?")
  user = User.create(first_name: first_name, last_name: last_name, email: email)
  puts "We added #{user.first_name} #{user.last_name} to our database! Thank you!"
  all_items = Item.order(:price).group_by{|i| i[:title]}
  item = prompt.select("What item would you like to buy?", all_items).first
  amount = prompt.ask("How many would you like to buy?")
  buy = Order.create(user: user, item: item, quantity: amount)
  puts "You have bought #{buy.quantity} of #{item.title}'s"
else
  puts "Have a nice day!"
end

# What item was ordered most often? Grossed the most money?
 most_order = Order.group(:item_id).sum(:quantity).items.first.title
 puts most_order

# What user spent the most?
# What were the top 3 highest grossing categories?
