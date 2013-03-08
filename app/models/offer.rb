require 'net/http'
require 'digest/sha1'

class Offer
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming

  define_model_callbacks :initialize

  DEFAULT_DATA = {
    'appid' =>        '157',
    'device_id' =>    '2b6f0cc904d137be2 e1730235f5664094b 831186',
    'locale' =>       'de',
    'ip' =>           '109.235.143.113',
    'offer_types' =>  '112'
  }
  API_KEY = APP['api_key']
  API_URL = APP['api_url']
  SIGN_NAME = APP['api_sign_name'] # just in case name is going to change one day

  attr_accessor :uid, :pub0, :page, :appid, :device_id, :locale, :ip, :offer_types, :api_key

  # Refer to docs pages 5-6 Parameters Overview for mandatory params
  validates_presence_of :appid, :uid, :locale, :device_id
  validates_numericality_of :page

  before_initialize :set_default_data

  def initialize(attributes = {})
    run_callbacks :initialize do
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end

  def persisted?
    false
  end

  # Parse the response and returns array of offers
  def get
    if result = make_request
      result['offers']
    else
      []
    end
  end

  # Makes a request to the server
  # Returns nil if a bad guy is chasing us or we have no response form the server
  def make_request
    url = URI.parse(request_uri)
    request = Net::HTTP::Get.new(url.to_s)
    response = Net::HTTP.start(url.host, url.port) { |http| http.request(request) }
    if response && valid_signature?(response)
      JSON.parse(response.body)
    else
      nil
    end
  end

  # Returns request uri after all the processing is done
  def request_uri
    params_str = generate_params
    hashkey = hash_params(params_str)
    "#{API_URL}?#{URI.escape(params_str)}&hashkey=#{hashkey}"
  end

  private

  def set_default_data
    DEFAULT_DATA.each do |name, value|
      send("#{name}=", value)
    end
  end

  # Adds timestap and create request string
  def generate_params
    params = instance_values
    params.merge!('timestamp' => Time.now.to_i)
    params.sort.map { |k, v| "#{k}=#{v}" }.join('&')
  end

  # Generates a hash key for the request using givien API_KEY
  # NOTE: That is tricky and interesting solution. IMHO
  def hash_params(str)
    Digest::SHA1.hexdigest "#{str}&#{API_KEY}"
  end

  # Check signature to protect us from man-in-the-middle attack
  def valid_signature?(response)
    response[SIGN_NAME] == Digest::SHA1.hexdigest(response.body.to_s + API_KEY)
  end
end