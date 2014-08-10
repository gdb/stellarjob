module Stellarjob::Twitter
  def self.bot
    @bot ||= create_bot
  end

  def self.tweet_reliably(msg, opts={})
    tries = 0

    puts "About to tweet: #{msg.inspect} #{opts.inspect}"

    while true
      begin
        tweet = bot.client.update(msg, opts)
      rescue Twitter::Error::Forbidden => e
        pause = 2 ** tries * 10
        tries += 1

        puts "Tweeting failed; going to sleep for #{pause} seconds"
        sleep(tries)
      else
        puts "Successfully tweeted: #{tweet.id}"
        return tweet
      end
    end
  end

  def self.create_bot
    bot = Chatterbot::Bot.new(Stellarjob::Config.config)
    # configure sending out tweets
    bot.debug_mode = false
    # configure updating the flat-file DB
    bot.no_update = false
    # configure being loud
    bot.verbose = true

    bot
  end
end
