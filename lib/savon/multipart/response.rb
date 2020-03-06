require 'mail'
require 'cgi'

module Savon
  module Multipart
    class Response < Savon::Response
      attr_reader :parts

      def initialize(*args)
        @parts = []
        super
      end

      def attachments
        if multipart?
          parse_body unless @has_parsed_body
          @parts.attachments
        else
          []
        end
      end

      def xml
        if multipart?
          parse_body unless @has_parsed_body
          if xop?
            parse_xop unless @has_parsed_xop
            @xop_body
          else
            @parts.first.body.to_s
          end
        else
          super
        end
      end

      private
      def multipart?
        !(http.headers['content-type'] =~ /^multipart/im).nil?
      end

      def xop?
        if multipart?
          parse_body unless @has_parsed_body
          !(@parts.first.header['content-type'].to_s =~ /^application\/xop\+xml/i).nil?
        else
          false
        end
      end

      def boundary
        return unless multipart?
        @boundary ||= Mail::Field.new('content-type', http.headers['content-type']).parameters['boundary']
      end

      def parse_body
        @parts = Mail::Part.new(
          :headers => http.headers,
          :body => http.body
        ).body.split!(boundary).parts
        @has_parsed_body = true
      end

      def parse_xop
        xml = @parts.first.body.to_s
        parsed = Nokogiri.XML(xml)
        xop_elements = parsed.xpath('//xop:Include', xop: "http://www.w3.org/2004/08/xop/include")
        if xop_elements.count == 0
          @xop_body = @parts.first.body.to_s
          @has_parsed_xop = true
          return
        end
        xop_elements.each do |xop_element|
          href = xop_element.attributes['href'].to_s
          cid = CGI.unescape(href[4..-1].to_s)
          data = @parts.find { |p| p.header['content-id'].to_s == "<#{cid}>" }.body.to_s
          xop_element.parent.content = Base64.encode64(data).chomp
        end
        @xop_body = parsed.to_s
        @has_parsed_xop = true
      end
    end
  end
end
