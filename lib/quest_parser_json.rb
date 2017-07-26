require 'net/http'
require 'uri'
require 'json'

class QuestParserJson
  SIGNIN_URL = '/login/signin'.freeze
  ENGINE_URL = '/gameengines/encounter/play/'.freeze
  FORMAT_URL = '?json=1'.freeze

  attr_accessor :domain_name, :game_id, :login, :password, :cookie, :errors, :level_json

  def initialize(domain_name, game_id)
    @domain_name = domain_name
    @game_id = game_id
    @cookie = ''
    @level_json = nil
    @login = nil
    @password = nil
    @errors = []
  end

  def get_html_from_url
    begin
      self.level_json = get_level
    rescue
      return false
    end
  end

  def parse_content(with_q_time)
    return if level_json.nil?

    # content = @page.search('.content')
    # if content
    #   parse_level_name(content)
    #   new_level = false
    #   if @level_name != @level_name_new
    #     @question_texts = []
    #     @question_texts_new = []
    #     @level_name = @level_name_new
    #     new_level = true
    #   end
    #   parse_questions(content, with_q_time, new_level)
    # end
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
      set_cookies(response)
    else
      self.errors = data['Message']
    end
  end

  def set_cookies(response)
    all_cookies = response.get_fields('set-cookie')
    cookies_array = []
    all_cookies.each do |cookie|
      cookies_array.push(cookie.split('; ')[0])
    end
    self.cookie = cookies_array.join('; ')
  end

  def get_level
    response = get_level_response
    if response.code == '200'
       JSON.parse response.body
    else
      sign_in
      unless errors.nil?
        response = get_level_response
        if response.code == '200'
          JSON.parse response.body
        else
          self.errors = 'Помилка отримання даних'
          nil
        end
      end
    end
  end

  def get_level_response
    uri = URI.parse("http://#{domain_name}#{ENGINE_URL}#{game_id}#{FORMAT_URL}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request['content-type'] = 'application/json'
    request['Cookie'] = self.cookie
    http.request request
  end
end