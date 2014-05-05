require 'mailgun'
require 'twitter'
require 'csv'


# Initialize Twitter API

client = Twitter::REST::Client.new do |config|
  config.consumer_key    = "XXXXXXXXXXXXXXXXXX" # Your API info goes here
  config.consumer_secret = "XXXXXXXXXXXXXXXXXX" # Your API info goes here
  config.access_token = "XXXXXXXXXXXXXXXXXX" # Your API info goes here
  config.access_token_secret = "XXXXXXXXXXXXXXXXXX" # Your API info goes here
end

# Search parameters & CSV engine with filtering

puts "Enter your search terms"
@terms = gets.chomp
puts "Maximum number of results? (enter a number)"
@result_count = gets.chomp.to_i
# puts "Enter an email address"
# @email = gets.chomp
CSV.open("my_results.csv", "wb") do |csv|
    counter = 0
    client.search(@terms).take(@result_count).each do |tweet|
        results = tweet.text
        if results.include? "http"
          x = URI.extract(results)
          row = ["Result ##{counter += 1} relating to '#{@terms}' -> #{x.join(" ")}"]
          csv << row
        else
          x = "fail"
        end
    end
end    

my_file = File.open("my_results.csv")

# Initialize Mailgun object:

Mailgun.configure do |config|
  config.api_key = "XXXXXXXXXXXXXXXXXX" # Your API info goes here
  config.domain  = 'XXXXXXXXXX' # Your Mailgun domain goes here
end

@mailgun = Mailgun()

# or alternatively:
@mailgun = Mailgun(:api_key => 'XXXXXXXXXXXXXX') # Your info here

parameters = {
  :to => 'recipient@email.com',
  :subject => "trendy subject",
  :text => "Lorem blah blah",
  :attachment => my_file,
  :from => "postmaster@yourmailgundomain.com"
}

@mailgun.messages.send_email(parameters)