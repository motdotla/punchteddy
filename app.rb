require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-sqlite-adapter'
require 'dm-postgres-adapter'
require 'data_mapper'
require 'tmail'
require 'postmark'
require 'json'

configure :development do
  DataMapper.setup(:default, "sqlite3://#{File.expand_path(File.dirname(__FILE__))}/db/punchteddy_development.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

configure do
  Postmark.api_key = "5e59334a-b4e1-4784-8405-1ac59c54ab1c"
  Postmark.response_parser_class = :Json
end

class Person
  include DataMapper::Resource
  include DataMapper::Timestamp
  
  # Schema
  property :id,                       Serial
  property :teddy,                    Boolean
  property :health,                   Integer, :default => 100
  property :punch_count,              Integer, :default => 0
  property :created_at,               DateTime
  property :updated_at,               DateTime
  
  def punch(person, hit_value=12)
    # change health on punched person
    person.health -= rand(hit_value)
    person.save
    # add to punch count
    self.punch_count += 1
    self.save
    # send_text_to_teddy
  end
  
  def send_text_to_teddy
    recipient = "9519701529@vtext.com"
    message = TMail::Mail.new
    # make sure you have a sender signature with that email
    # from and to also accept arrays of emails.
    message.from = "scott@spitfiresky.com"
    message.to = recipient
    message.subject = ""
    message.content_type = "text/plain"
    message["Message-Id"] = "<#{recipient}>"
    message.body = "You've been punched, Teddy! ~http://punchteddy.heroku.com"
    # tag message
    message.tag = "punchteddy"
    # set reply to if you need; also, you can pass array of emails.
    message.reply_to = "punchteddy@scottmotte.com"
    
    Postmark.send_through_postmark(message)
  end
  
  
end

get '/' do
  @teddy  = Person.new(:teddy => true)
  @teddy.save
  @you    = Person.new
  @you.save
  haml :index
end

get "/punchteddy/:teddy/:you" do
  punch_sayings = ["Punch Teddy!", "Punch!", "Punch him again!", "Sock him!", "Knock him out!", "Hit him harder!", "Kick him!", "Be violent to Teddy!", "Karate Chop Teddy!", "Punch him already!", "Punch him faster!"]
  
  teddy_response = ["Chill out Brochacho", "My muscles are too much for you", "I am the Asian persuasion", "That hurt...a little beat.", "Weak sauce boss.", "You are kaput.", "Your punches remind me of TGIF.", "Dammit, I think someone just pinched me.", "Son of a gun.", "Say no to beating me up...and to drugs.", "Stop it", "Stop it please", "What the heck mister man!", "That's messed up man", "You broke my brokeberry.", "Sweeet", "Your punches feel like a massage from my girlfriend.", "So bored", "Dammmmmmit", "Brochacho!", "Stop looking so weak.", "My mom punches harder than that", "Your mom punches harder than that", "Your mom is awesome.", "Cougars.", "You punch like a little girl.", "Give me something to look forward to.", "Can't you punch any harder than that."]
  
    teddy_punch_response = ["I am strong than you", "You're like a mosquito", "My muscles glisten", "My smile could beat you up", "Ha, take that", "This is fun", "My fists are like lightening", "Judo chop", "My muscles are glistening", "Get some muscles"]
  
  
  
  @you    = Person.get(params[:you])
  @teddy  = Person.get(params[:teddy])
  @teddy_punched_you = false
  @you.punch(@teddy)
  
  if rand(3) == 0
    @teddy_response = teddy_punch_response[rand(teddy_punch_response.length-1)]
    @teddy_punched_you = true
    @teddy.punch(@you, 35)
  else
    @teddy_response = teddy_response[rand(teddy_response.length-1)]
  end
  
  haml :punchteddy
end