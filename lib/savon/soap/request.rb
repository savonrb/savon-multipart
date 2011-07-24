module Savon
  module SOAP
    class Request

    private

      def setup(request, soap)
        request.url = soap.endpoint
        if soap.has_parts? # do multipart stuff if soap has parts
          request_message = soap.request_message
          # takes relevant http headers from the "Mail" message and makes them Net::HTTP compatible
          request.headers["Content-Type"] ||= ContentType[soap.version]
          request_message.header.fields.each do |field|
            request.headers[field.name] = field.to_s
          end
          #request.headers["Content-Type"] << %|; start="<savon_soap_xml_part>"|
          request_message.body.set_sort_order soap.parts_sort_order if soap.parts_sort_order && soap.parts_sort_order.any?
          request.body = request_message.body.encoded
        else
          request.headers["Content-Type"] ||= ContentType[soap.version]
          request.body = soap.to_xml
        end
        request
      end

    end
  end
end
