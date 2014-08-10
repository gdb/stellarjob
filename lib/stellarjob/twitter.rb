module Stellarjob::Twitter
  def self.bot
    @bot ||= create_bot
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
