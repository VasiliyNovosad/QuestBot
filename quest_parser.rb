require 'open-uri'
require 'mechanize'

# http://zhitomir.quest.ua/gameengines/encounter/play/41977
# http://quest.ua/Login.aspx

class QuestParser
  attr_accessor :page, :level_name, :level_name_new, :question_texts, :question_texts_new, :url, :type_url, :login, :password, :errors

  def initialize(page_url, url_type)
    @level_name = ''
    @question_texts = []
    @question_texts_new = []
    @url = page_url
    @type_url = url_type
    @agent = Mechanize.new
    @login = nil
    @password = nil
    @errors = []
  end

  def get_html_from_url
    if type_url == 'file'
      @page = File.open(@url) { |f| Nokogiri::HTML(f) } # Nokogiri::HTML(html)
    else
      #@doc = Nokogiri::HTML(open(url))
      @page = @agent.get(@url)
      if need_log_in
        if @login.nil? || @password.nil?
          @errors.push('Login empty!!! Set login with command .setlogin "login" in private chat')  if @login.nil?
          @errors.push('Password empty!!! Set password with command .setpassword "password" in private chat')  if @password.nil?
          return false
        end
        login_form = @page.form
        if login_form
          login_form.Login = @login
          login_form.Password = @password
          login_form.submit
        end
      end
      @page = @agent.get(@url)
    end
    true
  end

  def parse_content(with_q_time)
    content = @page.search('.content')
    if content
      parse_level_name(content)
      if @level_name != @level_name_new
        @question_texts = []
        @question_texts_new = []
        @level_name = @level_name_new
      end
      parse_questions(content, with_q_time)
    end
  end

  def send_code(code)
    code_form = @page.form
    if code_form && code_form['LevelAction.Answer']
      code_form['LevelAction.Answer'] = code
      code_form.submit
    end
  end

  def parse_needed_sectors
    content = @page.search('.content')
    founded = []
    if content
      sectors = content.css('.cols-wrapper p')
      if sectors
        p sectors.count
        sectors.each do |sector|
          p "#{sector.children[0].text} #{sector.children[1].children[0].text}"
          if sector.children[1].children[0].text == 'код не введён' || sector.children[1].children[0].text == 'code is not entered'
            founded.push(sector.children[0].text.strip.gsub(':', ''))
          end
        end
      end
    end
    founded.uniq
  end

  def parse_full_info
    content = @page.search('.content')
    full_info = []
    if content && content.children
      content.children.each do |el|
        question_text = parse_element(el)
        # puts question_text
        if question_text && question_text != '' && question_text != "\n"
          if !/^Бонус (\d+|\d+: \d+)$/.match(question_text) &&
              /^(?!(Бонус \d+: \d+ \(осталось))/.match(question_text)
            # p question_text
            full_info.push(question_text)
          end
        end
      end
    end
    full_info
  end

  private

  def need_log_in
    @page.form && (@page.form.button_with(value: 'Вход') || @page.form.button_with(value: 'Sign In'))
  end

  def parse_level_name(content)
    level = content.at_css('h2')
    @level_name_new = level.children.map { |c| c.name == 'span' ? c.children[0].text : c.text }.join if level && level.children
  end

  def parse_element(element)
    case element.name
      when 'img'
        element.attributes['src']
      when 'a'
        "#{element.children.count == 0 ? remove_tab_from_text(element.text) : element.children.map { |c| parse_element(c) }.join(' ')} ( #{element.attributes['href']} )"
      when 'br'
        "\n"
      when 'script', 'style', 'div', 'table'
        ''
      when /^h\d/
        "\n#{element.children.count == 0 ? remove_tab_from_text(element.text) : element.children.map { |c| parse_element(c) }.join(' ')}"
      else
        if element.class.name == 'Nokogiri::XML::Comment'
          ''
        else
          element.children.count == 0 ? remove_tab_from_text(element.text) : element.children.map do |c|
            parse_element(c)
          end.join(' ')
        end
    end
  end

  def remove_tab_from_text(text)
    text.gsub("\r", '').gsub("\n", '').gsub("\t", '').gsub('&nbsp', ' ').strip
  end

  def parse_questions(content, with_q_time)
    @question_texts_new = []
    question_texts_from_content = content.children # css('h3, h3 + p')
    question_texts_from_content.each do |el|
      question_text = parse_element(el)
      puts question_text
      if question_text && question_text != '' && question_text != "\n" && !@question_texts.include?(question_text) &&
          !(/^Бонус (\d+|\d+: \d+)$/ =~ question_text.strip) && /^(?!(Бонус \d+: \d+ \(осталось))/.match(question_text.strip)
        unless !with_q_time && (/Автопереход на следующий уровень через/ =~ question_text && @question_texts.grep(/Автопереход на следующий уровень через/).count >= 1 ||
            /Autopass to the next level in/ =~ question_text && @question_texts.grep(/Autopass to the next level in/).count >= 1 ||
            /^Подсказка 1  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 1  будет через/).count >= 1 ||
            /^Подсказка 2  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 2  будет через/).count >= 1 ||
            /^Подсказка 3  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 3  будет через/).count >= 1 ||
            /^Подсказка 4  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 4  будет через/).count >= 1 ||
            /^Подсказка 5  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 5  будет через/).count >= 1 ||
            /^Подсказка 6  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 6  будет через/).count >= 1 ||
            /^Подсказка 7  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 7  будет через/).count >= 1 ||
            /^Подсказка 8  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 8  будет через/).count >= 1 ||
            /^Подсказка 9  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 9  будет через/).count >= 1 ||
            /^Подсказка 10  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 10  будет через/).count >= 1 ||
            /^Подсказка 11  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 11  будет через/).count >= 1 ||
            /^Подсказка 12  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 12  будет через/).count >= 1 ||
            /^Подсказка 13  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 13  будет через/).count >= 1 ||
            /^Подсказка 14  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 14  будет через/).count >= 1 ||
            /^Подсказка 15  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 15  будет через/).count >= 1 ||
            /^Подсказка 16  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 16  будет через/).count >= 1 ||
            /^Подсказка 17  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 17  будет через/).count >= 1 ||
            /^Подсказка 18  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 18  будет через/).count >= 1 ||
            /^Подсказка 19  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 19  будет через/).count >= 1 ||
            /^Подсказка 20  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 20  будет через/).count >= 1)
          @question_texts_new.push(question_text)
        end
      end
    end

  end

end