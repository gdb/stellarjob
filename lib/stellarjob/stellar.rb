require 'cgi'
require 'rest_client'

module Stellarjob::Stellar
  def self.stellarjob_account_id
    Stellarjob::Config.config.fetch(:stellar_account_id)
  end

  def self.stellarjob_secret
    Stellarjob::Config.config.fetch(:stellar_secret)
  end

  def self.account_to_username(account)
    begin
      response = RestClient.get("https://api.stellar.org/reverseFederation?domain=stellar.org&type=reverse_federation&destination_address=#{CGI.escape(account)}")
    rescue RestClient::ResourceNotFound
      puts "No username found for #{account}"
    else
      JSON.parse(response).
        fetch('federation_json').
        fetch('destination')
    end
  end

  def self.send_points(destination, value)
    request('submit', secret: stellarjob_secret, tx_json: {
        TransactionType: 'Payment',
        Account: stellarjob_account_id,
        Destination: destination,
        Amount: {
          currency: '+++',
          value: value,
          issuer: stellarjob_account_id
        }
      })
  end

  def self.account_lines(account)
    request('account_lines', account: account)
  end

  def self.request(method, *params)
    body = JSON.generate(method: method, params: params)

    begin
      response = RestClient.post('http://live.stellar.org:9002', body)
    rescue RestClient::BadRequest => e
      puts "Failed request: error=#{e.inspect}"
      raise
    end

    JSON.parse(response)
  end
end
