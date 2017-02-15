require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require 'pry'
require_relative 'models/user'
require_relative 'models/order'
require_relative 'models/item'
require_relative 'models/address'

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)

  # binding.pry
  # Explorer
    # 1 How many users are there?
    puts "#{User.count} users"
    # 2 What are the 5 most expensive items?
    items = Item.order(:price).last(5)
    items.each do |item|
      puts "#{item.title} costs #{item.price} Bitcoins"
    end
    #3 What's the cheapest book?
    params = "book"
    puts Item.order(:price).where("category LIKE :params", {:params => "%#{params}%"}).first.title

    #4
      # 1 Who lives at "6439 Zetta Hills, Willmouth, WY"?
      street = "6439 Zetta Hills"
      city = "Willmouth"
      state = "WY"
      user = Address.find_by(street: street, city: city, state: state).user
      puts "#{user.first_name} #{user.last_name}"
      # 2 Do they have another address?
      addresses = []
      Address.where(user_id: user.id).find_each do |address|
          if Address.find_by(street: street, city: city, state: state) != address
            street_address = address.street
            city_address = address.city
            state_address = address.state
            addresses << {street: street_address, city: city_address, state: state_address}
          end
        end
        addresses.each do |address|
          puts "#{address[:street]}, #{address[:city]}, #{address[:state]}"
        end
    # 5 Correct Virginie Mitchell's address to "New York, NY, 10108".
    address = User.find_by(first_name: "Virginie", last_name: "Mitchell").addresses.find_by(state: "NY").update(city: "New York", zip: 10108)
    if address == true
      puts "true"
    else
      puts "false"
    end

    new_address = User.find_by(first_name: "Virginie", last_name: "Mitchell").addresses.find_by(state: "NY")
    puts new_address.inspect
    # 6 How much would it cost to buy one of each tool?
    params = "tool"
    puts Item.where("category LIKE :params", {:params => "%#{params}%"}).sum("price")
    # 7 How many total items did we sell?
    puts Order.sum("quantity")
    # 8 How much was spent on books?
    params = "book"
    puts Order.joins("INNER JOIN items ON orders.item_id = items.id").where("items.category LIKE :params", {:params => "%#{params}%"}).sum("items.price * orders.quantity")

  # Adventure
    # 1 Simulate buying an item by inserting a User from command line input (ask the user for their information) and an Order for that User (have them pick what they'd like to order and other needed order information).
    # prompt = TTY::Prompt.new
    #
    #
    # prompt
    #
    #
    # user = User.create(first_name: fname, last_name: lname, email: email)
    # order = Order.create(user_id: user.id, item_id: item_id, quantity: quantity)
    # puts

    # 2
      # 1 What item was ordered most often?

      # 2 Grossed the most money?

    # 3 What user spent the most?

    # 4 What were the top 3 highest grossing categories?
