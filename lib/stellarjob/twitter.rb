module Stellarjob::Twitter
  def self.bot
    @bot ||= create_bot
  end

  def self.tweet_reliably(*args)
    tries = 0
    while true
      tweet = Stellarjob::Twitter.tweet_reliably(*args)
      return tweet if tweet

      pause = 2 ** tries * 10
      tries += 1

      puts "Tweeting failed; going to sleep for #{pause} seconds"
      sleep(tries)
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
