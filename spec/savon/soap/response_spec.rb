require 'savon-multipart'

describe Savon::Multipart::Response do

  before do
    @header = { "Content-Type" => 'multipart/related; boundary="--==_mimepart_4d416ae62fd32_201a8043814c4724"; charset=UTF-8; type="text/xml"' }
    path = File.expand_path("../../../fixtures/response/multipart.txt", __FILE__)
    raise ArgumentError, "Unable to load: #{path}" unless File.exist? path
    @body = File.read(path)
  end

  it "parses without Exception" do
    response = soap_response :headers => @header, :body => @body
    response.to_xml.should == '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:wsdl="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><ns1:TransactionID soapenv:actor="" soapenv:mustUnderstand="1" xsi:type="xsd:string" xmlns:ns1="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2">2011012713535811111111111</ns1:TransactionID></soapenv:Header><soapenv:Body><SubmitReq xmlns="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2"><MM7Version>5.3.0</MM7Version><SenderIdentification><VASPID>messaging</VASPID><VASID>ADM</VASID><SenderAddress><ShortCode>1111</ShortCode></SenderAddress></SenderIdentification><Recipients><To><Number>11111111111</Number></To></Recipients><ServiceCode>1</ServiceCode><MessageClass>Personal</MessageClass><ExpiryDate>2011-01-28T13:53:58Z</ExpiryDate><DeliveryReport>false</DeliveryReport><ReadReply>false</ReadReply><Priority>Normal</Priority><Subject>Test MMS via Savon</Subject><ChargedParty>Sender</ChargedParty><Content href="cid:attachment_1" allowAdaptations="true"/></SubmitReq></soapenv:Body></soapenv:Envelope>'
    response.parts.length.should == 2
    response.parts[1].parts.length.should == 3
    response.parts[1].parts[2].body.should == "This is a test message from Github"
  end

  it "returns a String from the #to_xml method" do
    body = File.read(File.expand_path('../../../fixtures/response/simple_multipart.txt', __FILE__))
    response = soap_response :headers => @header, :body => body
    response.to_xml.class.should == String
  end

  it "returns a Hash from the #body method" do
    body = File.read(File.expand_path('../../../fixtures/response/simple_multipart.txt', __FILE__))
    response = soap_response :headers => @header, :body => body
    response.body.class.should == Hash
    response.body.should == {:submit_req => true}
  end

  it "returns the attachments" do
    response = soap_response :headers => @header, :body => @body
    response.attachments.size.should == 1
  end

  it "parses soap messages without attachments too" do
    header = { 'Content-Type' => 'text/html; charset=utf-8'}
    body = File.read(File.expand_path('../../../fixtures/response/not_multipart.txt', __FILE__))
    response = soap_response :headers => header, :body => body

    response.to_xml.chomp.should == '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:wsdl="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><ns1:TransactionID soapenv:actor="" soapenv:mustUnderstand="1" xsi:type="xsd:string" xmlns:ns1="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2">2011012713535811111111111</ns1:TransactionID></soapenv:Header><soapenv:Body><SubmitReq xmlns="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2"><MM7Version>5.3.0</MM7Version><SenderIdentification><VASPID>messaging</VASPID><VASID>ADM</VASID><SenderAddress><ShortCode>1111</ShortCode></SenderAddress></SenderIdentification><Recipients><To><Number>11111111111</Number></To></Recipients><ServiceCode>1</ServiceCode><MessageClass>Personal</MessageClass><ExpiryDate>2011-01-28T13:53:58Z</ExpiryDate><DeliveryReport>false</DeliveryReport><ReadReply>false</ReadReply><Priority>Normal</Priority><Subject>Test MMS via Savon</Subject><ChargedParty>Sender</ChargedParty><Content href="cid:attachment_1" allowAdaptations="true"/></SubmitReq></soapenv:Body></soapenv:Envelope>'
    response.parts.size.should == 0
    response.attachments.size.should == 0
  end

  it "only parses the SOAP body once" do
    response = soap_response :headers => @header, :body => @body
    response.to_xml

    counter = 0
    subbed_parse_body = lambda { counter += 1 }
    response.class.send(:define_method, :parse_body, subbed_parse_body)
    5.times { response.attachments }

    counter.should == 0
  end

  def soap_response(options = {})
    defaults = { :code => 200, :headers => {}, :body => "" }
    response = defaults.merge options
    globals = {
      :multipart => true,
      :convert_response_tags_to  => lambda { |tag| tag.snakecase.to_sym}
    }
    http = HTTPI::Response.new(response[:code], response[:headers], response[:body])

    Savon::Multipart::Response.new(http, globals, {})
  end
end
