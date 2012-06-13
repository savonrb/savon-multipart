require "savon/soap/part"

module Savon
  module SOAP
    class Response

      # Overwrite to +decode_multipart+.
      def initialize(config, response)
        self.http = response
        decode_multipart
        raise_errors if config.raise_errors
      end

      def parts
        @parts || []
      end

      attr_writer :parts

      # Returns +true+ if this is a multipart response.
      def multipart?
        http.headers["Content-Type"] =~ /^multipart/
      end

      # Returns the boundary declaration of the multipart response.
      def boundary
        return unless multipart?
        @boundary ||= Mail::Field.new("Content-Type", http.headers["Content-Type"]).parameters['boundary']
      end

      # Returns the Array of attachments if it was a multipart response.
      def attachments
        parts.attachments
      end

      # Overwrite to work with multipart response.
      def to_xml
        if multipart?
          parts.first.body.decoded  # we just assume the first part is the XML
        else
          http.body
        end
      end

    private

      # Decoding multipart responses.
      #
      # <tt>response.to_xml</tt> will point to the first part, hopefully the SOAP part of the multipart.
      # All attachments are available in the <tt>response.parts</tt> Array. Each is a Part from the mail gem.
      # See the docs there for details but:
      #
      # * response.parts[0].body is the contents
      # * response.parts[0].headers are the mime headers
      #
      # And you can do nesting:
      #
      # * response.parts[0].parts[2].body
      def decode_multipart
        return unless multipart?
        part_of_parts = Part.new(:headers => http.headers, :body => http.body)
        part_of_parts.body.split!(boundary)
        self.parts = part_of_parts.parts
      end

    end
  end
end
