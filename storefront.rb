require 'rubygems'
require 'bundler/setup'
require 'tty'
require 'active_record'
require 'sqlite3'
require 'pry'
require_relative 'models/user'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/store.sqlite3'
)

# Your code here

puts User.count
binding.pry
