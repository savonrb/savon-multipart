# frozen_string_literal: true

require 'mail'
require 'cgi'

module Savon
  module Multipart
    # Savon::Response subclass that understands multipart/related SOAP
    # responses, exposing MIME parts, attachments and XOP content.
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
        return super unless multipart?

        parse_body unless @has_parsed_body
        multipart_xml
      end

      private

      def multipart_xml
        if xop?
          parse_xop unless @has_parsed_xop
          @xop_body
        else
          @parts.first.body.to_s
        end
      end

      def multipart?
        !(http.headers['content-type'] =~ /^multipart/im).nil?
      end

      def xop?
        if multipart?
          parse_body unless @has_parsed_body
          !(@parts.first.header['content-type'].to_s =~ %r{^application/xop\+xml}i).nil?
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
          headers: http.headers,
          body: http.body
        ).body.split!(boundary).parts
        @has_parsed_body = true
      end

      def parse_xop
        parsed = Nokogiri.XML(@parts.first.body.to_s)
        xop_elements = parsed.xpath('//xop:Include', xop: 'http://www.w3.org/2004/08/xop/include')

        if xop_elements.empty?
          @xop_body = @parts.first.body.to_s
        else
          replace_xop_includes(xop_elements)
          @xop_body = parsed.to_s
        end
        @has_parsed_xop = true
      end

      def replace_xop_includes(xop_elements)
        xop_elements.each do |xop_element|
          href = xop_element.attributes['href'].to_s
          cid = CGI.unescape(href[4..])
          data = find_part_by_cid(cid).body.to_s
          xop_element.parent.content = Base64.encode64(data).chomp
        end
      end

      def find_part_by_cid(cid)
        @parts.find { |part| part.header['content-id'].to_s == "<#{cid}>" }
      end
    end
  end
end
