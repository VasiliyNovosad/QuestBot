require 'net/http'
require 'uri'
require 'json'
require_relative '../lib/level'

class QuestParserJson
  SIGNIN_URL = '/login/signin'.freeze
  ENGINE_URL = '/gameengines/encounter/play/'.freeze
  FORMAT_URL = '?json=1'.freeze

  attr_accessor :domain_name, :game_id, :login, :password, :cookie, :errors, :level

  def initialize(domain_name, game_id)
    @domain_name = domain_name
    @game_id = game_id
    @cookie = ''
    @level = Level.new({})
    @login = nil
    @password = nil
    @errors = nil
  end

  # Отримати повну інформацію про поточний рівень
  def full_info
    begin
      level_json = get_level
      return nil if level_json.nil? || level_json['Level'].nil?
      level.full_info(level_json)
    rescue
      return nil
    end
  end

  # Отримати оновлену інформацію про поточний рівень
  def updated_info(with_q_time)
    begin
      level_json = get_level
      return nil if level_json.nil? || level_json['Level'].nil?
      level.updated_info(level_json, with_q_time)
    rescue
      return nil
    end
  end

  # Надіслати код
  def send_answer(code)
    resp = send_code(level.id, level.number, code)
    correct_answer?(resp)
  end

  # Отримати список незакритих секторів
  def parse_needed_sectors
    begin
      level_json = get_level
      return nil if level_json.nil? || level_json['Level'].nil?
      level.needed_sectors(level_json)
    rescue
      return nil
    end
  end

  # Отримати список секторів із кодами
  def parse_all_sectors
    begin
      level_json = get_level
      return nil if level_json.nil? || level_json['Level'].nil?
      level.all_sectors(level_json)
    rescue
      return nil
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
    sign_in
    if errors.nil?
      response = get_level_response
      if response.code == '200'
        JSON.parse response.body
      else
        self.errors = 'Помилка отримання даних'
        nil
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

  def send_code(level_id, level_number, code)
    sign_in
    if errors.nil?
      response = send_code_response(level_id, level_number, code)
      if response.code == '200'
        JSON.parse response.body
      else
        self.errors = 'Помилка отримання даних'
        nil
      end
    end
  end

  def send_code_response(level_id, level_number, code)
    uri = URI.parse("http://#{domain_name}#{ENGINE_URL}#{game_id}#{FORMAT_URL}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request['content-type'] = 'application/json'
    request['Cookie'] = cookie
    body = { 'LevelId' => level_id, 'LevelNumber' => level_number, 'LevelAction.Answer' => code }
    request.body = body.to_json
    http.request(request)
  end

  def correct_answer?(response)
    response['EngineAction']['LevelAction']['IsCorrectAnswer'] unless response.nil?
  end

end