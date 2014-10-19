require 'nokogiri'
require 'open-uri'

module Ruboty
  module Handlers
    class SlideMe < Base
      on /slide me/, name: 'slide_me', description: '今日のアツいスライドを表示'

      def slide_me(message)
        message.reply(slide_message)
      rescue => e
        message.reply(e.message)
      end

      private

      def url
        "http://slidegate.herokuapp.com/#{Time.now.strftime("%Y/%m/%d")}"
      end

      def html
        OpenURI.open_uri(url).read
      end

      def slides
        Nokogiri::HTML(html).search('tr').drop(1).map {|tr|
          {
            url:    tr.css('td')[1].at_css('a')['href'],
            text:   tr.css('td')[1].text,
            hatebu: tr.css('td')[3].text.to_i
          }
        }
      end

      def slide_message
        slides.map {|slide|
          indent = slide.keys.map(&:to_s).map(&:size).max
          slide.map {|k,v| "%-#{indent}s: #{v}" % k }.join($/)
        }.join($/ * 2)
      end
    end
  end
end
