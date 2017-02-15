
require 'pry'
require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require_relative 'models/address'
require_relative 'models/item'
require_relative 'models/order'
require_relative 'models/user'


ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)



# Your code here
# binding.pry

#Explorer Mode:
# 1) How many users are there?
#    Native SQL: select count(*) from users

puts "The number of users in the table is #{User.count}"

#2 What are the 5 most expensive items?
#  Native SQL:  select * from items order by price desc limit 5;
# THis is a call by hash argument, notice the colon on price

items = Item.order(price: :desc).first(5)
puts "#{items.inspect}"

puts "Five Highest Price Items: "

items.each do |x|
   puts "  #{x.id} #{x.title} #{x.category} #{x.description} #{x.price}"
end

#3 What's the cheapest book?
#  Native SQL:  select * from items where category = 'book' order by price limit 1;
#      price is a symbol in this case, notice where the colon is
# select * from items where category like '%book%' order by price;
 puts "cheapest where 'book' "
 items = Item.where(category: 'book')
 items.each do |x|
   puts "  #{x.id} #{x.title} #{x.category} #{x.description} #{x.price}"
 end

 puts "cheapest where 'Books' getting only first from yesterday "
 items = Item.order(:price).where(category: 'Books').first
 puts "  #{items.id} #{items.title} #{items.category} #{items.description} #{items.price}"


 puts "cheapest where like 'books' getting only first from yesterday "
 items = Item.order(:price).where("category LIKE '%books%'").first
 puts "  #{items.id} #{items.title} #{items.category} #{items.description} #{items.price}"

# 4)Who lives at "6439 Zetta Hills, Willmouth, WY"? Do they have another address?


  person = User.joins("INNER JOIN addresses ON users.id = addresses.user_id")
    .where("addresses.street = '6439 Zetta Hills'")
    .where("addresses.city = 'Willmouth'")
    .where("addresses.state = 'WY'").first

    puts " #{person.first_name} #{person.last_name} (ID #{person.id}) lives at 6439 Zetta Hills, Willmouth, WY"

    the_person = person.id.to_i

    addresses = Address.where("user_id = #{the_person}")
    puts "She has two addresses:"
    addresses.each do |z|
       puts "#{z.street} #{z.city} #{z.state} #{z.zip}"
    end

# 5) Correct Virginie Mitchell's address to "New York, NY, 10108"
#     select addresses.id, *
#       from users join addresses
#       where users.id = user_id and first_name = "Virginie" and last_name = "Mitchell"
#              and state = "NY" ;
# update addresses set city = "New York", zip = 10108 where id =
# ( select addresses.id from users join addresses where users.id = user_id and first_name = "Virginie" and last_name = "Mitchell" and state = "NY" ) ;

    virginie_NY_address = User.joins("INNER JOIN addresses on users.id = addresses.user_id ")
      .where("users.first_name = 'Virginie'").first

    id_number = virginie_NY_address.id.to_i


    address_to_update = Address.where("user_id = #{id_number}").first

    address_to_update.city = "New York"
    address_to_update.zip = "10108"

    address_to_update.save

# 6) How much would it cost to buy one of each tool?
#    Native SQL:  select sum(price) from items where category like '%tools%';
#    sum(price) 46477

total = Item.where("category like '%tools%'").sum("price")
puts "Tool cost to buy 1 of each: #{total}"

# 7) How many total items did we sell?
#    select sum(quantity) from orders; sum(quantity) 2125

total = Order.sum("quantity")
puts "Total quantity sold: #{total}"



# 8) How much was spent on books
#     sum(price*quantity)
#         1081352

book_total = Order.joins("INNER JOIN items on orders.item_id = items.id")
   .where("items.category like '%book%'")
   .sum("orders.quantity*items.price")
  puts "Book Total: #{book_total.inspect}"









#---------------------------------------------------------------
