require 'open-uri'
require 'mechanize'

class QuestParser
  attr_accessor :page, :level_name, :level_name_new, :question_texts,
                :question_texts_new, :url, :type_url, :login, :password, :errors

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
      begin
        @page = @agent.get(@url)
        return false if @page.nil?
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
      rescue
        return false
      end
    end
    true
  end

  def parse_content(with_q_time)
    # content = @page.search('.gameCongratulation')
    # if content
    #   @question_texts = []
    #   @level_name_new = 'Finish'
    #   @level_name = @level_name_new
    #   parse_finish_info(content)
    #   return
    # end
    return if @page.nil?
    content = @page.search('.content')
    if content
      parse_level_name(content)
      new_level = false
      if @level_name != @level_name_new
        @question_texts = []
        @question_texts_new = []
        @level_name = @level_name_new
        new_level = true
      end
      parse_questions(content, with_q_time, new_level)
    end
  end

  def get_correct_codes
    return if @page.nil?
    correct_codes = []
    content = @page.search('.history span.color_correct')
    correct_codes += content.map { |el| el.text.strip.downcase }.uniq
    content = @page.search('.history span.color_bonus')
    correct_codes += content.map { |el| el.text.strip.downcase }.uniq
    correct_codes.uniq
  end

  def send_code(code)
    return if @page.nil?
    code_form = @page.form
    if code_form && code_form['LevelAction.Answer']
      code_form['LevelAction.Answer'] = code
      code_form.submit
    end
  end

  def parse_needed_sectors
    return if @page.nil?
    content = @page.search('.content')
    founded = []
    if content
      sectors = content.css('.cols-wrapper p')
      if sectors
        # p sectors.count
        sectors.each do |sector|
          # p "#{sector.children[0].text} #{sector.children[1].children[0].text}"
          if sector.children[1].children[0].text == 'код не введён' || sector.children[1].children[0].text == 'code is not entered'
            founded.push(sector.children[0].text.strip.gsub(':', ''))
          end
        end
      end
    end
    founded.uniq
  end

  def parse_all_sectors
    return if @page.nil?
    content = @page.search('.content')
    founded = []
    if content
      sectors = content.css('.cols-wrapper p')
      if sectors
        # p sectors.count
        sectors.each do |sector|
          # p "#{sector.children[0].text} #{sector.children[1].children[0].text}"
          text = sector.children[1].children[0].text
          if sector.children[1].children[0].text == 'код не введён' || sector.children[1].children[0].text == 'code is not entered'
            text = '-'
          end
          founded.push(sector.children[0].text.strip.gsub(':', '') + ': ' + text)
        end
      end
    end
    founded
  end

  def parse_full_info
    return if @page.nil?
    content = @page.search('.content')
    full_info = []
    if !content.nil? && !content.children.nil?
      content.children.each do |el|
        question_text = parse_element(el)
        # puts question_text
        if question_text && question_text != '' && question_text != "\n"
          # if !/^Бонус (\d+|\d+: \d+)$/.match(question_text) &&
          #     /^(?!(Бонус .*\(осталось))/.match(question_text)
            # p question_text
          full_info.push(question_text)
          # end
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
    @level_name_new = level.children.map { |c| c.name == 'span' ? c.children[0].text : c.text }.join if !level.nil? && !level.children.nil?
  end

  def parse_element(element)
    case element.name
      when 'img'
        element.attributes['src']
      when 'a'
        "#{element.children.count.zero? ? remove_tab_from_text(element.text) : element.children.map { |c| parse_element(c) }.join(' ')} ( #{element.attributes['href']} )"
      when 'br'
        "\n"
      when 'style', 'div'
        ''
      when 'script'
        element.text =~ /(-?\d+(\.\d+)?)(\.| )\s*(-?\d+(\.\d+)?)/ ? element.text.match(/(-?\d+(\.\d+)?)(\.| )\s*(-?\d+(\.\d+)?)/)[0] + "\n" : ''
      when 'table'
        element.attributes['class'].nil? ? parse_table(element) : ''
      when /^h\d/
        if element.children.count.zero?
          "\n#{remove_tab_from_text(element.text)}"
        else
          text = element.children.map { |c| parse_element(c) }
          "\n#{text.join(' ')}"
        end
      else
        if element.class.name == 'Nokogiri::XML::Comment'
          ''
        elsif element.children.count.zero?
          remove_tab_from_text(element.text)
        else
          element.children.map do |c|
            parse_element(c)
          end.join(' ')
        end
    end
  end

  def parse_table(element)
    element.css('tr').map do |row|
      row.css('td').map{ |el| parse_element(el)}.join(' : ')
    end.join("\n")
  end

  def remove_tab_from_text(text)
    text.gsub("\r", '').gsub("\n", '').gsub("\t", '').gsub('&nbsp', ' ').strip
  end

  def parse_finish_info(content)
    @question_texts_new = []
    question_texts_from_content = content.at_css('div.t_center')
    question_texts_from_content.children.each do |el|
      question_text = parse_element(el)
      @question_texts_new.push(question_text)
    end
  end

  def parse_questions(content, with_q_time, new_level = false)
    @question_texts_new = []
    question_texts_from_content = content.children # css('h3, h3 + p')
    question_texts_from_content.each do |el|
      question_text = parse_element(el)
      # puts question_text
      if question_text && question_text != '' && question_text != "\n" && !@question_texts.include?(question_text) &&
          (new_level || !(/^Бонус (\d+|\d+: \d+)$/ =~ question_text.strip) &&
          /^(?!(Бонус .*\(осталось))/.match(question_text.strip))
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
            /^Подсказка 20  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 20  будет через/).count >= 1 ||
            /^Подсказка 21  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 21  будет через/).count >= 1 ||
            /^Подсказка 22  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 22  будет через/).count >= 1 ||
            /^Подсказка 23  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 23  будет через/).count >= 1 ||
            /^Подсказка 24  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 24  будет через/).count >= 1 ||
            /^Подсказка 25  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 25  будет через/).count >= 1 ||
            /^Подсказка 26  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 26  будет через/).count >= 1 ||
            /^Подсказка 27  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 27  будет через/).count >= 1 ||
            /^Подсказка 28  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 28  будет через/).count >= 1 ||
            /^Подсказка 29  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 29  будет через/).count >= 1 ||
            /^Подсказка 30  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 30  будет через/).count >= 1 ||
            /^Подсказка 31  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 31  будет через/).count >= 1 ||
            /^Подсказка 32  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 32  будет через/).count >= 1 ||
            /^Подсказка 33  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 33  будет через/).count >= 1 ||
            /^Подсказка 34  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 34  будет через/).count >= 1 ||
            /^Подсказка 35  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 35  будет через/).count >= 1 ||
            /^Подсказка 36  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 36  будет через/).count >= 1 ||
            /^Подсказка 37  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 37  будет через/).count >= 1 ||
            /^Подсказка 38  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 38  будет через/).count >= 1 ||
            /^Подсказка 39  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 39  будет через/).count >= 1 ||
            /^Подсказка 40  будет через/ =~ question_text && @question_texts.grep(/^Подсказка 40  будет через/).count >= 1 ||
            /^Штрафная подсказка 1  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 1  будет через/).count >= 1 ||
            /^Штрафная подсказка 2  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 2  будет через/).count >= 1 ||
            /^Штрафная подсказка 3  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 3  будет через/).count >= 1 ||
            /^Штрафная подсказка 4  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 4  будет через/).count >= 1 ||
            /^Штрафная подсказка 5  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 5  будет через/).count >= 1 ||
            /^Штрафная подсказка 6  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 6  будет через/).count >= 1 ||
            /^Штрафная подсказка 7  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 7  будет через/).count >= 1 ||
            /^Штрафная подсказка 8  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 8  будет через/).count >= 1 ||
            /^Штрафная подсказка 9  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 9  будет через/).count >= 1 ||
            /^Штрафная подсказка 10  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 10  будет через/).count >= 1 ||
            /^Штрафная подсказка 11  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 11  будет через/).count >= 1 ||
            /^Штрафная подсказка 12  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 12  будет через/).count >= 1 ||
            /^Штрафная подсказка 13  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 13  будет через/).count >= 1 ||
            /^Штрафная подсказка 14  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 14  будет через/).count >= 1 ||
            /^Штрафная подсказка 15  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 15  будет через/).count >= 1 ||
            /^Штрафная подсказка 16  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 16  будет через/).count >= 1 ||
            /^Штрафная подсказка 17  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 17  будет через/).count >= 1 ||
            /^Штрафная подсказка 18  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 18  будет через/).count >= 1 ||
            /^Штрафная подсказка 19  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 19  будет через/).count >= 1 ||
            /^Штрафная подсказка 20  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 20  будет через/).count >= 1 ||
            /^Штрафная подсказка 21  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 21  будет через/).count >= 1 ||
            /^Штрафная подсказка 22  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 22  будет через/).count >= 1 ||
            /^Штрафная подсказка 23  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 23  будет через/).count >= 1 ||
            /^Штрафная подсказка 24  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 24  будет через/).count >= 1 ||
            /^Штрафная подсказка 25  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 25  будет через/).count >= 1 ||
            /^Штрафная подсказка 26  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 26  будет через/).count >= 1 ||
            /^Штрафная подсказка 27  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 27  будет через/).count >= 1 ||
            /^Штрафная подсказка 28  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 28  будет через/).count >= 1 ||
            /^Штрафная подсказка 29  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 29  будет через/).count >= 1 ||
            /^Штрафная подсказка 30  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 30  будет через/).count >= 1 ||
            /^Штрафная подсказка 31  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 31  будет через/).count >= 1 ||
            /^Штрафная подсказка 32  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 32  будет через/).count >= 1 ||
            /^Штрафная подсказка 33  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 33  будет через/).count >= 1 ||
            /^Штрафная подсказка 34  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 34  будет через/).count >= 1 ||
            /^Штрафная подсказка 35  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 35  будет через/).count >= 1 ||
            /^Штрафная подсказка 36  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 36  будет через/).count >= 1 ||
            /^Штрафная подсказка 37  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 37  будет через/).count >= 1 ||
            /^Штрафная подсказка 38  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 38  будет через/).count >= 1 ||
            /^Штрафная подсказка 39  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 39  будет через/).count >= 1 ||
            /^Штрафная подсказка 40  будет через/ =~ question_text && @question_texts.grep(/^Штрафная подсказка 40  будет через/).count >= 1)
          @question_texts_new.push(question_text)
        end
      end
    end
  end
end