module BotUtils
  def seconds_to_string(seconds, nominative = false)
    result = ''
    if seconds / 3600 > 0
      result << time_part_to_text(seconds / 3600, 'годин', nominative)
    end
    if (seconds / 60) % 60 > 0
      result << time_part_to_text((seconds / 60) % 60, 'хвилин', nominative)
    end
    if seconds % 60 > 0
      result << time_part_to_text(seconds % 60, 'секунд', nominative)
    end
    result
  end

  def parsed(text)
    coords = []
    result = text

    ire = %r{<img.+?src="\s*(https?://.+?)\s*".*?>}
    ireA = /<a.+?href=?"(https?:\/\/.+?.(jpg|png|bmp))?".*?>(.*?)<\/a>/

    reBr = %r{</*br\s*/?>}
    reHr = %r{<hr.*?/?>}
    reP = %r{<p>([\s\S.]+?)</p>}
    reBold = %r{<b.*?/?>([\s\S.]+?)</b>}
    reStrong = %r{<strong.*?>([\s\S.]*?)</strong>}
    reItalic = %r{<i>([\s\S.]+?)</i>}
    reStyle = %r{<style.*?>([\s\S.]*?)</style>}
    reScript = %r{<script.*?>([\s\S.]*?)</script>}
    reSpan = %r{<span.*?>([\s\S.]*?)</span>}
    reCenter = %r{<center>([\s\S.]+?)</center>}
    reFont = %r{<font.+?colors*=?["«]?#?(w+)?["»]?.*?>([\s\S.]+?)</font>}
    reA = %r{<a.+?href=?"(.+?)?".*?>(.+?)</a>}
    reTable = %r{<table.*?>([\s\S.]*?)</table>}
    reTr = %r{<tr.*?>([\s\S.]*?)</tr>}
    reTd = %r{<td.*?>([\s\S.]*?)</td>}


    # <a href="https://www.google.com.ua/maps/place/50%C2%B044'33.4%22N+25%C2%B028'26.2%22E/@50.7407788,25.4743992,378m/data=!3m1!1e3!4m5!3m4!1s0x0:0x0!8m2!3d50.7426!4d25.473939?hl=uk" target="blank">50.742600,25.473939</a>
    # <a href="geo:49.976136, 36.267256">49.976136, 36.267256</a>
    geoHrefRe = %r{<a.+?href="geo:(\d{1,3}[.,]\d{3,}),?\s*(-*\d{1,2}[.,]\d{3,})">(.+?)</a>}

    # <a href="https://www.google.com.ua/maps/@50.0363257,36.2120039,19z" target="blank">50.036435 36.211914</a>
    hrefRe = %r{<a.+?href="https?://.+?(\d{1,3}[.,]\d{3,}),?\s*(-*\d{1,2}[.,]\d{3,}).*?">(.+?)</a>}

    # 49.976136, 36.267256
    numbersRe = /(\d{1,3}[.,]\d{3,}),?\s*(-*\d{1,2}[.,]\d{3,})/


    mrStyle = result.to_enum(:scan, reStyle).map { Regexp.last_match }
    mrStyle.each { |match| result = result.gsub(match[0], '') }

    mrScript = result.to_enum(:scan, reScript).map { Regexp.last_match }
    mrScript.each { |match| result = result.gsub(match[0], '') }
    result = result.gsub("_", "\\_").gsub("*", "\\*")

    mrFont = result.to_enum(:scan, reFont).map { Regexp.last_match }
    mrFont.each { |match| result = result.gsub(match[0], match[2]) }

    mrBold = result.to_enum(:scan, reBold).map { Regexp.last_match }
    mrBold.each { |match| result = result.gsub(match[0], "*#{match[1]}*") }

    mrStrong = result.to_enum(:scan, reStrong).map { Regexp.last_match }
    mrStrong.each { |match| result = result.gsub(match[0], "*#{match[1]}*") }

    mrItalic = result.to_enum(:scan, reItalic).map { Regexp.last_match }
    mrItalic.each { |match| result = result.gsub(match[0], "#{match[1]}") }

    mrGeoHrefRe = result.to_enum(:scan, geoHrefRe).map { Regexp.last_match }
    mrGeoHrefRe.each do |match|
      result = result.gsub(match[0], "#{match[1]}, #{match[2]}")
      unless coords.any? { |coord| coord[:latitude] == match[1] && coord[:longitude] == match[2] }
        coords << { latitude: match[1], longitude: match[2], name: match[3] }
      end
    end

    mrHrefRe = result.to_enum(:scan, hrefRe).map { Regexp.last_match }
    mrHrefRe.each do |match|
      # result = result.gsub(match[0], "#{match[3]}: #{match[1]}, #{match[2]}")
      # unless coords.any? { |coord| coord[:latitude] == match[1] && coord[:longitude] == match[2] }
      #   coords << { latitude: match[1], longitude: match[2], name: match[3] }
      # end
      result = result.gsub(match[0], "#{match[3]}")
    end

    mrNumbersRe = result.to_enum(:scan, numbersRe).map { Regexp.last_match }
    mrNumbersRe.each do |match|
      # result = result.gsub(
      #   # match[0],
      #   # "[#{match[1]} #{match[2]}] (#{google_link(match[1], match[2])})"
      # )
      unless coords.any? { |coord| coord[:latitude] == match[1] && coord[:longitude] == match[2] }
        coords << { latitude: match[1], longitude: match[2], name: "#{match[1]}, #{match[2]}" }
      end
    end

    mrSpan = result.to_enum(:scan, reSpan).map { Regexp.last_match }
    mrSpan.each { |match| result = result.gsub(match[0], match[1]) }

    mrCenter = result.to_enum(:scan, reCenter).map { Regexp.last_match }
    mrCenter.each { |match| result = result.gsub(match[0], match[1]) }

    mre = result.to_enum(:scan, ire).map { Regexp.last_match }
    mre.each { |match| result = result.gsub(match[0], match[1]) }

    mreA = result.to_enum(:scan, ireA).map { Regexp.last_match }
    mreA.each { |match| result.gsub!(match[0], match[1]) }

    mrA = result.to_enum(:scan, reA).map { Regexp.last_match }
    mrA.each { |match| result = result.gsub(match[0], "[#{match[2]}](#{match[1]})") }

    mrP = result.to_enum(:scan, reP).map { Regexp.last_match }
    mrP.each { |match| result = result.gsub(match[0], "\n#{match[1]}") }

    mrBr = result.to_enum(:scan, reBr).map { Regexp.last_match }
    mrBr.each { |match| result = result.gsub(match[0], "\n") }

    mrHr = result.to_enum(:scan, reHr).map { Regexp.last_match }
    mrHr.each { |match| result = result.gsub(match[0], "\n") }

    mrTd = result.to_enum(:scan, reTd).map { Regexp.last_match }
    mrTd.each { |match| result = result.gsub(match[0], "#{match[1]} : ") }

    mrTr = result.to_enum(:scan, reTr).map { Regexp.last_match }
    mrTr.each { |match| result = result.gsub(match[0], "#{match[1]}\n") }

    mrTable = result.to_enum(:scan, reTable).map { Regexp.last_match }
    mrTable.each { |match| result = result.gsub(match[0], match[1]) }

    result = result.gsub('&nbsp;', ' ')
    result = result.gsub("\r", '')
    { text: result.gsub("\n\n\n", "\n\n"), coords: coords }
  end

  private

  def time_part_to_text(count, part, nominative)
    result = ''
    case count % 10
      when 1
        result << (nominative ? "#{count} #{part}а " : "#{count} #{part}у ")
      when 2..4
        result << "#{count} #{part}и "
      else
        result << "#{count} #{part} "
    end
    result
  end

end
