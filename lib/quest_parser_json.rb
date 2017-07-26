require 'net/http'
require 'uri'
require 'json'

class QuestParserJson
  SIGNIN_URL = '/login/signin'.freeze
  ENGINE_URL = '/gameengines/encounter/play/'.freeze
  FORMAT_URL = '?json=1'.freeze

  attr_accessor :domain_name, :game_id, :login, :password, :cookie, :errors, :level_json

  def get_html_from_url
    begin
      get_level_json
    rescue
      return false
    end
  end

  private

  def sign_in
    uri = URI.parse("http://#{domain_name}#{SIGNIN_URL}#{FORMAT_URL}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request['content-type'] = 'application/json'
    request.body = { 'Login' => login, 'Password' => password }.to_json
    response = http.request(request)
    data = JSON.parse response.body
    if data['Error'].zero?
      all_cookies = response.get_fields('set-cookie')
      cookies_array = []
      all_cookies.each do |cookie|
        cookies_array.push(cookie.split('; ')[0])
      end
      self.cookie = cookies_array.join('; ')
    else
      self.errors = data['Message']
    end
  end

  def get_level_json
    uri = URI.parse("http://#{domain_name}#{ENGINE_URL}#{game_id}#{FORMAT_URL}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request['content-type'] = 'application/json'
    request['Cookie'] = cookie
    response = http.request request
    if response.code == '200'
      self.level_json = JSON.parse response.body
    else
      sign_in
      unless errors.nil?
        uri = URI.parse("http://#{domain_name}#{ENGINE_URL}#{game_id}#{FORMAT_URL}")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        request['content-type'] = 'application/json'
        request['Cookie'] = cookie
        response = http.request request
        if response.code == '200'
          self.level_json = JSON.parse response.body
        else
          self.errors = 'Помилка отримання даних'
        end
      end
    end
  end
end