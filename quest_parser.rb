require 'open-uri'
require 'mechanize'

# http://zhitomir.quest.ua/gameengines/encounter/play/41977
# http://quest.ua/Login.aspx

class QuestParser
  attr_accessor :page, :level_name, :level_name_new, :question_headers, :question_headers_new, :question_texts, :question_texts_new, :url, :type_url

  def initialize(page_url, url_type)
    @level_name = ''
    @question_headers = []
    @question_headers_new = []
    @question_texts = []
    @question_texts_new = []
    @url = page_url
    @type_url = url_type
    @agent = Mechanize.new
  end

  def get_html_from_url

    if type_url == 'file'
      @page = File.open(@url) { |f| Nokogiri::HTML(f) } # Nokogiri::HTML(html)
    else
      #@doc = Nokogiri::HTML(open(url))
      @page = @agent.get(@url)
      if need_log_in
        login_form = @page.form
        login_form.Login = 'vnovosad'
        login_form.Password = 'V0rtex'
        login_form.submit
      end
      @page = @agent.get(@url)
    end
  end

  def parse_content
    content = @page.search('.content')
    parse_level_name(content)
    if @level_name != @level_name_new
      @question_texts = []
      @question_texts_new = []
    end
    parse_questions(content)
  end

  def send_code(code)
    code_form = @page.form
    code_form['LevelAction.Answer'] = code
    code_form.submit
  end

  def parse_needed_sectors
    content = @page.search('.content')
    founded = []
    sectors = content.css('.cols-wrapper p')
    sectors.each do |sector|
      if sector.children[1].children[0].text == 'код не введён'
        founded.push(sector.children[0].text.strip.gsub(':', ''))
      end
    end
    founded.uniq
  end

  private

  def need_log_in
    @page.form.button_with(value: 'Вход')
  end

  def parse_level_name(content)
    level = content.at_css('h2')
    @level_name_new = level.children.map { |c| c.name == 'span' ? c.children[0].text : c.text }.join
  end

  def parse_element(element)
    case element.name
      when 'img'
        element.attributes['src']
      when 'a'
        ": #{element.attributes['href']}"
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
    text.gsub("\r", '').gsub("\n", '').gsub("\t", '').strip
  end

  def parse_questions(content)
    @question_texts_new = []
    question_texts_from_content = content.children # css('h3, h3 + p')
    question_texts_from_content.each do |el|
      question_text = parse_element(el)
      # puts question_text
      if question_text && question_text != '' && question_text != "\n" && !@question_texts.include?(question_text)
        if !/^Бонус (\d+|\d+: \d+)$/.match(question_text) &&
            /^(?!(Бонус \d+: \d+ \(осталось))/.match(question_text)
          # p question_text
          @question_texts_new.push(question_text)
        end
      end
    end

  end

end