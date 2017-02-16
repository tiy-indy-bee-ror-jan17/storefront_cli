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
require_relative 'models/review/'

# ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)

###### Explorer Mode
puts"\n"
# How many users are there?
puts "There are #{User.count} users."

# What are the 5 most expensive items?
puts "The five most expensive items are:"
Item.order(price: :desc).limit(5).each do |item|
  puts " #{item.title} costs $#{item.price}"
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

######### Adventure Mode

# What item was ordered most often? Grossed the most money?
 most_order = Order.joins(:item).order("sum_orders_quantity desc").group(:title).sum("orders.quantity").first
 puts "#{most_order.first} was ordered the most."

 gross = Order.joins(:item).order("sum_orders_quantity_all_items_price desc").group(:title).sum("orders.quantity * items.price").first
 puts "#{gross.first} grossed the most money."

# What user spent the most?

baller = Order.joins(:user, :item).order("sum_orders_quantity_all_items_price desc").group("users.id").sum("orders.quantity * items.price").first
baller_name = User.where("id = ?", baller.first).first
puts "#{baller_name.first_name} #{baller_name.last_name} spent the most money.\n\n"
## There has to be a better way to do this

# What were the top 3 highest grossing categories?

gc = Item.joins(:orders).order("sum_orders_quantity_all_items_price").reverse_order.group("items.category").sum("orders.quantity * items.price").first(3)
puts "The top 3 grossing categories were:\n #{gc[0].first} with $#{gc[0].last},\n #{gc[1].first} with $#{gc[1].last},\n and #{gc[2].first} with $#{gc[2].last}."
## Note: Research how to do adventure mode better

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

#Putting this out of order so when the script is run it outputs all of the information and then does the prompts


###### Epic Mode

# unfinished epic mode prompt
#Can i put a condition where if the email doesn't exist return something?
#This only works when I'm returning it as an array/hash
#I could add a Y/N confirmation loop to check ordered item

if prompt.yes?("Would you like to leave a review?")
  find_email = prompt.ask("What is your email used when buying an item?")
  find_id = User.where("email = ?", find_email).first.id
  find_item = Order.where("user_id = ?", find_id).first
  item = Item.where("id = ?", find_item.item_id).first
  stars = prompt.ask("How many stars (1-5) do you want to rate #{item.title}?")
  review = prompt.ask("Please write your review of the item.")
  Review.create(item_id: find_item.item_id, user_id: find_id, stars: stars, review: review)
  puts "Your review is greatly appreciated!"
else
  puts "Have a great day!"
end
