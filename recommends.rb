require 'rubygems'
require 'neography'
require 'sinatra'
require 'uri'

def generate_text(length=8)
  chars = 'abcdefghjkmnpqrstuvwxyz'
  key = ''
  length.times { |i| key << chars[rand(chars.length)] }
  key
end

def create_graph
  neo = Neography::Rest.new
  graph_exists = neo.get_node_properties(1)
  return if graph_exists && graph_exists['name']
  commands = []
  
  items = %w[AlchemyDB CouchDB Cassandra Datomic Dex 
             Hadoop Hypertable InfiniteGraph InfoGrid Membase 
             MongoDB Neo4j OrientDB RavenDB Redis 
             Riak Scalaris SimpleDB Tokyo-Cabinet Voldemort]
  
              
  items.each{ |n| commands << [:create_node, {"name" => n}]}

  users = %w[Aaron Achyuta Adam Adel Agam Alex Allison Amit Andreas Andrey 
             Andy Anne Barry Ben Bill Bob Brian Bruce Chris Corey 
             Dan Dave Dean Denis Eli Eric Esteban Ezl Fawad Gabriel 
             James Jason Jeff Jennifer Jim Jon Joe John Jonathan Justin 
             Karen Kim Kiril Heather Helene Isabella Lisa LeRoy Lester Mark 
             Mary Max Maykel Michael Mike Musannif Namkyu Neil Nick Nirajan 
             Patrick Paulo Pete Peter Phillip Pinaki Pramod Prasanna Ray Rob 
             Rachel Rose Ross Ryan Sam Samantha Sandeep Sandy Satpreet Satya 
             Savannah Shane Sharif Songsin Stephen Steve Sulabh Tabitha Tarah Thomas 
             Tim Toby Tom Trish Webber Wendy Xiao Yogesh Yoshi Zach]
             
  users.each{ |n| commands << [:create_node, {"name" => n}]}

  items.each_index do |item|
    commands << [:add_node_to_index, "items_index", "name", items[item], "{#{item}}"]
  end

  users.each_index do |user| 
    user_id = user + items.size
    commands << [:add_node_to_index, "users_index", "type", users[user], "{#{user_id}}"]
    connected = []

    # create likes relationships
    
    likes = items.map{|n| items.index(n)}.sample(1 + rand(5))
    likes.each do |item_id|
      commands << [:create_relationship, "likes", "{#{user_id}}", "{#{item_id}}", {:weight => 1 + rand(5)}]
    end    
   end
   batch_result = neo.batch *commands
end