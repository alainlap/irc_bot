require "socket"
require 'nokogiri'
require 'open-uri'
require "./jokes"

class IRC_Bot

  def initialize server, port, nick, channel
    @irc_server = server
    @port = port
    @nick = nick
    @channel = channel

    @news_counter = 0
  end

  def run
    @server = TCPSocket.open(@irc_server, @port)
    @server.puts "USER #{@nick} 0 * #{@nick}"
    @server.puts "NICK #{@nick}"
    @server.puts "JOIN #{@channel}"
    say("Hi, I'm a bot. I can tell you the time, news or a joke. Just type !time, !news or !time")

    until @server.eof? do
      msg = @server.gets
      puts msg
      ping(msg)
      respond_to(msg.downcase)
    end
  end

  def ping(msg)
    send_ping = false
    send_ping = msg.include? "PING"
    if send_ping
      @server.puts msg.gsub("PING", "PONG")
    end
  end

  def say(msg)
    @server.puts "PRIVMSG #{@channel} :#{msg}"
  end

  def convert(num)
    ones = %w(zero one two three four five six seven eight nine ten)
    teens = %w(zero eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen)
    tens = %w(zero ten twenty thirty fourty fifty sixty)

    output = ""

    if num <= 10
      output << ones[num]
    elsif num > 10 && num < 20
      output << teens[num-10]
    elsif num % 10 == 0
      output = tens[num/10]
    elsif num >= 20
      first_part = num / 10
      output << tens[first_part] + "-"
      second_part = num % 10
      output << ones[second_part]
    end
    output
  end

  def username(msg)
    msg.slice(1..(msg.index('!') - 1)) if msg.include?('!')
  end

  def respond_to(msg)
    if msg.include?("privmsg #{@channel} :")
      
      # HERE ARE SOME THINGS I CAN DO
      tell_jokes(msg)
      tell_time(msg)
      say_headlines(msg)
      # say_random_things
    end
  end

  def tell_jokes(msg)
    say_joke = false
    if msg.include?("!joke")
      say("#{JOKES[rand(JOKES.length)]}")
    end
  end

  def tell_time(msg)
    say_time = false
    if msg.include?("!time")
      time = Time.now
      hour = time.hour
      min = time.min
      ampm = "in the morning"

      if hour > 12
        ampm = "in the afternoon"
        ampm = "in the evening" if hour > 17
        hour -= 12
      end

      hour = convert(hour)
      min = convert(min)

      say("#{username(msg)}: It is #{hour} #{min} #{ampm}.")
    end
  end

  def say_random_things
    say(RAN[rand(RAN.length)])
    sleep 30
  end

  def say_headlines(msg)
    say_headlines = false
    if msg.include?("!news")
      headlines = pull_headlines
      headline_to_read = @news_counter % headlines.length
      say(headlines[headline_to_read])
      @news_counter += 1
    end
  end

  def pull_headlines
    doc = Nokogiri::HTML(open('http://www.cbc.ca/news'))
    headlines = []
    doc.css(".pinnableHeadline").each do |item|
      headlines << item.text
    end
    headlines
  end

end


ircbot = IRC_Bot.new("chat.freenode.net", "6667", "NewsBot", "#bitmakerlabs")
ircbot.run
