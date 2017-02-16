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


# Explorer Mode

# How many users are there?
puts User.count

# What are the 5 most expensive items?
items = Item.order(price: :desc).limit(5)
items.each do |item|
  puts item.title
end

# What's the cheapest book? (Does that change for "category is exactly 'book'" versus "category contains 'book'"?)
cheap = Item.where("category like ?", '%book%').order(price: :asc).first
puts "#{cheap.title} is the cheapest book."

# Who lives at "6439 Zetta Hills, Willmouth, WY"? Do they have another address?
who = Address.where(street: '6439 Zetta Hills', city: 'Willmouth', state: 'WY').first
puts "#{who.user.first_name} #{who.user.last_name} lives at this address."

corrine = User.find_by(first_name: 'Corrine', last_name: 'Little')
other = corrine.addresses.where("id != ?", who.id)
other.each do |address|
  puts "She also has an address at #{address.street}, #{address.city}, #{address.state}, #{address.zip}"
end

# Correct Virginie Mitchell's address to "New York, NY, 10108".
virg = User.find_by(first_name: 'Virginie', last_name: 'Mitchell')
virg.addresses.update(city: 'New York', state: 'NY', zip: '10108')

# How much would it cost to buy one of each tool?
cost = Item.where("category like ?", '%tools%').sum(:price)
puts "One of each tool would cost #{cost}"

# How many total items did we sell?
puts "#{Order.all.sum(:quantity)} items were sold."

# How much was spent on books?
books = Item.where('category like ?', '%books%')
books_total = 0
books.each do |book|
  if book.orders.length > 0
    books_total += book.orders.map(&:quantity).reduce(:+) * book.price
  end
end
puts "#{books_total} was spent on books."



# Adventurer Mode
#
# # Simulate buying an item by inserting a User from command line input (ask the user for their information) and an Order for that User (have them pick what they'd like to order and other needed order information).
prompt = TTY::Prompt.new

first_name = prompt.ask("Please enter your first name.")
last_name = prompt.ask("Please enter your last name.")
email = prompt.ask("Please enter your email.")

new_user = User.create(first_name: first_name, last_name: last_name, email: email)
puts "User #{first_name} #{last_name} added."

item_id = prompt.ask("Please enter an item ID (1-100).")
quantity = prompt.ask("How many would you like?")

new_order = Order.create(user_id: new_user.id, item_id: item_id, quantity: quantity)
puts "You ordered #{new_order.quantity} of #{new_order.item.title}"


# What item was ordered most often? Grossed the most money?
Order.group(:item_id).order('count_id').count('id')    # According to Stack Overflow, calling .count names the column 'count_(arg)'
top_items = Item.where('id = ? or id = ? or id = ?', 10, 46, 65)
items = top_items.map(&:title)
puts "Most popular items were #{items.join(' and ')}"

order_hash = Hash.new(0)
Order.all.each do |order|
  order_hash[order.item_id] += (order.quantity * order.item.price)
end

order_hash.sort_by { |item_id, value| value }.reverse
popular = Item.find_by(id: 65)
puts "#{popular.title} grossed the most money."

# What user spent the most?
big_spender = Hash.new(0)
Order.all.each do |order|
  big_spender[order.user_id] += (order.quantity * order.item.price)
end

big_spender.sort_by { |user_id, value| value }.reverse.first
big = User.find_by(id: 19)    # Crap, this made me realize that my homework from yesterday was wrong. I see why.
puts "#{big.first_name} #{big.last_name} spent the most."

# What were the top 3 highest grossing categories?      # Trying a join
highest_gross = Order.joins(:item).group(:category).order('sum_quantity_all_price desc').limit(3).sum('quantity * price')  # .order argument found in error message
puts "Highest grossing categories were #{highest_gross.map { |category, value| category }.join(' and ')}"


#
# Epic Mode
#
# Create a new table and model to store reviews of items in the sqlite3 console.
# The reviews table should contain an item_id, a user_id, an integer value from 1-5 that gives the star rating, and text that contains the review.
# Create a command line interface that allows a user to find themselves by email address, pick an item they've ordered and leave a review on it.
