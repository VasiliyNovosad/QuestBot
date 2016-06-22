require 'open-uri'
require 'nokogiri'

class QuestParser
  attr_accessor :level_name, :level_name_new, :question_headers, :question_headers_new, :question_texts, :question_texts_new, :url, :type_url, :doc

  def initialize(page_url, url_type)
    level_name = ''
    question_headers = {}
    question_texts = {}
    url = page_url
    type_url = url_type
  end

  def get_html_from_url
    if type_url == 'file'
      doc = File.open(url) { |f| Nokogiri::HTML(f) } # Nokogiri::HTML(html)
    else
      doc = Nokogiri::HTML(open(url))
    end
  end

  def parse_content
    content = doc.css('.content')
    parse_level_name(content)
    parse_question(content)
  end

  private

  def parse_level_name(content)
    level = content.at_css('h2')
    level_name_new = level.children.map { |c| c.name == 'span' ? c.children[0].text : c.text }.join
  end

  def parse_questions(content)
    question_headers = content.css('h3')
    question_headers.each do |el|
      if el.attributes['class'].nil?
        question_header = el.text
        unless question_headers.include?(question_header)
          question_headers_new.push(question_header)
          question_headers.push(question_header)
        end
      end
    end

    question_texts = content.css('h3 + p')
    question_texts.each do |el|
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
        question_texts_new.push(question_text)
        question_texts.push(question_text)
      end
    end

  end

end