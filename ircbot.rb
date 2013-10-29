require "socket"
require "./jokes"

class IRC_Bot

  def initialize

    @irc_server = "chat.freenode.net"
    @port = "6667"
    @nick = "bangrowboat"
    @channel = "#bitmakerlabs"  
  end

  def run

    @server = TCPSocket.open(@irc_server, @port)
    @server
    @server.puts "USER bhellobot 0 * BHelloBot"
    @server.puts "NICK #{@nick}"
    @server.puts "JOIN #{@channel}"
    @server.puts "PRIVMSG #{@channel} :Hi, I'm a boat"

    until @server.eof? do
      respond_to(@server.gets.downcase)
    end
  end

  def respond_to(msg)

    msg = @server.gets.downcase
    puts msg

    if msg.include? "privmsg #bitmakerlabs :"
      greeting(msg)
      tell_jokes(msg)
      quit(msg)
    end
  end

  def greeting(msg)
    say_greeting = false
    greetings = ["hello", "hi", "hola", "yo", "wazup", "guten tag", "howdy", "salutations", "who the hell are you?", "bonjour"]
    greetings.each do |greeting|
      say_greeting = true if (msg.include? greeting)
    end
    say("Hello. Want to hear a joke? : Say 'joke'") if say_greeting
  end

  def tell_jokes(msg)
    say_joke = false
    if msg.include? "joke"
      random_joke = JOKES[rand(JOKES.length)]
      say(random_joke)
    end
  end

  def quit(msg)
    leave = false
    quit_msgs = ["go away", "quit", "leave", "get out", "exit"]
    quit_msgs.each do |q|
      leave = true if (msg.include? q)
    end
    if leave    
      say("See you later!")
      exit
    end
  end

  def say(msg)
    @server.puts "PRIVMSG #{@channel} :#{msg}"
  end
end


rowboat = IRC_Bot.new
rowboat.run

