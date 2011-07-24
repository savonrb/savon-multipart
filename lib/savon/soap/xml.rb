require "savon/soap/part"

module Savon
  module SOAP
    class XML

      # Use sort functionality in  Mail::Body.sort!() to order parts.
      # An array of mime types is expected.
      # E.g. this makes the xml appear before an attached image: ["text/xml", "image/jpeg"]
      attr_accessor :parts_sort_order

      # Adds a Part object to the current SOAP "message".
      # Parts are really attachments.
      def add_part(part)
        @parts ||= Array.new
        @parts << part
      end

      # Check if any parts have been added.
      def has_parts?
        @parts ||= Array.new
        !@parts.empty?
      end

      # Returns the mime message for a multipart request.
      def request_message
        return if @parts.empty?

        @request_message = Part.new do
          content_type 'multipart/related; type="text/xml"'
        end

        soap_body = self.to_xml
        soap_message = Part.new do
          content_type 'text/xml; charset=utf-8'
          add_content_transfer_encoding
          body soap_body
        end
        soap_message.add_content_id "<savon_soap_xml_part>"
        @request_message.add_part(soap_message)
        @parts.each do |part|
          @request_message.add_part(part)
        end
        #puts @request_message
        @request_message
      end

    end
  end
end
