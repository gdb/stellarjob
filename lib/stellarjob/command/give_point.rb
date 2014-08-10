class Stellarjob::GivePoint
  def self.handle(*args)
    plus_plus = self.new(*args)
    plus_plus.run
  end

  def initialize(tweet, sender, recipient, reason)
    @tweet = tweet
    @sender = sender
    @recipient = recipient
    @reason = reason
  end

  def bot
    Stellarjob::Twitter.bot
  end

  def run
    puts "Processing +++ from #{@sender} -> #{@recipient}"

    if @sender == @recipient
      bot.tweet("@#{@sender}: You can't +++ yourself!", in_reply_to_status_id: @tweet.id)
      return
    end

    if user = Stellarjob::Model::User.first(twitter_username: @recipient)
      handle_existing_user(user)
    elsif link_attempt = Stellarjob::Model::LinkAttempt.first(
        twitter_username: @recipient,
        active: true
        )
      handle_pending_link(link_attempt)
    else
      handle_new_link
    end

    bot.favorite(@tweet)
  end

  def handle_existing_user(user)
    puts "Going to send 1 +++ to existing user #{user}"

    user.send_points!(1)
    bot.tweet("@#{@recipient}: You've been +++'d by @#{@sender} for a total of #{user.total_from_network}: https://www.stellar.org/viewer/#live/#{user.stellar_account}", in_reply_to_status_id: @tweet.id)
  end

  def handle_pending_link(link_attempt)
    puts "Reminding new user about a pending link"

    # Maybe turn this into an inc.
    link_attempt.pending_points += 1
    link_attempt.save!

    bot.tweet("@#{@recipient}: You've been +++'d by @#{@sender}. Congrats!", in_reply_to_status_id: @tweet.id)
    bot.tweet("@#{@recipient}: You have #{link_attempt.pending_points} +++ points pending. Link your Stellar account here: https://gdb.github.io/stellarjob/##{link_attempt.link_amount}.", in_reply_to_status_id: @tweet.id)
  end

  def handle_new_link
    puts "Asking new user to sign up"

    link_attempt = Stellarjob::Model::LinkAttempt.generate(
      twitter_username: @recipient
      )

    bot.tweet("@#{@recipient}: You've been +++'d by @#{@sender}. Congrats!", in_reply_to_status_id: @tweet.id)
    bot.tweet("@#{@recipient}: Receive your +++ points by linking your Stellar account here: https://gdb.github.io/stellarjob/##{link_attempt.link_amount}.", in_reply_to_status_id: @tweet.id)
  end
end
