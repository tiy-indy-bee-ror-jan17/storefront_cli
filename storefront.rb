
require 'pry'
require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require_relative 'models/user'

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)


#binding.pry
# Your code here


User.all.each do |x|
  puts "Users: #{x.id} #{x.first_name} #{x.last_name} #{x.email}"
end

puts "The number of users in the table is #{User.count}"
