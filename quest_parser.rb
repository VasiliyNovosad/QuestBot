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
    parse_questions(content)
  end

  def send_code(code)
    code_form = @page.form
    code_form['LevelAction.Answer'] = code
    code_form.submit
    parse_content
  end

  private

  def need_log_in
    @page.form.button_with(value: 'Вход')
  end

  def parse_level_name(content)
    level = content.at_css('h2')
    @level_name_new = level.children.map { |c| c.name == 'span' ? c.children[0].text : c.text }.join
  end

  def parse_questions(content)
    @question_headers_new = []
    @question_texts_new = []
    question_headers_from_content = content.css('h3')
    question_headers_from_content.each do |el|
      if el.attributes['class'].nil?
        question_header = el.text
        unless question_headers.include?(question_header)
          @question_headers_new.push(question_header)
        end
      end
    end

    question_texts_from_content = content.css('h3 + p')
    question_texts_from_content.each do |el|
      question_text = ''
      el.children.each do |row|
        case row.name
          when 'img'
            question_text += row.attributes['src']
          when 'br'
          else
            question_text += row.text
        end
      end
      question_text.gsub!("\r", "\n")
      puts question_text
      unless question_texts.include?(question_text)
        @question_texts_new.push(question_text)
      end
    end

  end

end