require 'savon-multipart'

RSpec.describe Savon::Multipart::Response do

  let(:header) {{ "Content-Type" => 'multipart/related; boundary="--==_mimepart_4d416ae62fd32_201a8043814c4724"; charset=UTF-8; type="text/xml"' }}
  let(:body) { File.read(path) }
  let(:response) { soap_response(:headers => header, :body => body) }

  def soap_response(options = {})
    defaults = { :code => 200, :headers => {}, :body => "" }
    response = defaults.merge options
    globals = {
      :multipart => true,
      :raise_errors => true,
      :convert_response_tags_to  => lambda { |tag| tag.snakecase.to_sym}
    }
    http = HTTPI::Response.new(response[:code], response[:headers], response[:body])

    Savon::Multipart::Response.new(http, globals, {})
  end

  context "multipart" do
    let(:path) { File.expand_path("../../../fixtures/response/multipart.txt", __FILE__) }

    it "parses without Exception" do
      expect(response.xml.strip).to eq('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:wsdl="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><ns1:TransactionID soapenv:actor="" soapenv:mustUnderstand="1" xsi:type="xsd:string" xmlns:ns1="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2">2011012713535811111111111</ns1:TransactionID></soapenv:Header><soapenv:Body><SubmitReq xmlns="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2"><MM7Version>5.3.0</MM7Version><SenderIdentification><VASPID>messaging</VASPID><VASID>ADM</VASID><SenderAddress><ShortCode>1111</ShortCode></SenderAddress></SenderIdentification><Recipients><To><Number>11111111111</Number></To></Recipients><ServiceCode>1</ServiceCode><MessageClass>Personal</MessageClass><ExpiryDate>2011-01-28T13:53:58Z</ExpiryDate><DeliveryReport>false</DeliveryReport><ReadReply>false</ReadReply><Priority>Normal</Priority><Subject>Test MMS via Savon</Subject><ChargedParty>Sender</ChargedParty><Content href="cid:attachment_1" allowAdaptations="true"/></SubmitReq></soapenv:Body></soapenv:Envelope>')
      expect(response.parts.length).to eq(2)
      expect(response.parts[1].parts.length).to eq(3)
      expect(response.parts[1].parts[2].body.decoded.strip).to eq("This is a test message from Github")
    end

    it "returns the attachments" do
      expect(response.attachments.size).to eq(1)
    end

    it "only parses the SOAP body once" do
      Mail::Part.stub(:new).and_return(double(Mail::Part).as_null_object)
      expect(Mail::Part).to receive(:new).exactly(1).times
      5.times { response.attachments }
    end
  end

  context "simple multipart" do
    let(:path) { File.expand_path('../../../fixtures/response/simple_multipart.txt', __FILE__) }

    it "returns a String from the #xml method" do
      expect(response.xml.class).to eq(String)
    end

    it "returns a Hash from the #body method" do
      expect(response.body.class).to eq(Hash)
      expect(response.body).to eq({:submit_req => true})
    end
  end

  context "simple xop" do
    let(:path) { File.expand_path('../../../fixtures/response/simple_xop.txt', __FILE__) }

    it "returns a String from the #xml method" do
      expect(response.xml.class).to eq(String)
    end

    it "returns a Hash from the #body method, include xop data" do
      expect(response.body.class).to eq(Hash)
      expect(response.body).to eq({:binary_data => Base64.encode64('BinaryDataGoesHere').chomp})
    end
  end

  describe "a multipart response with case sensitive headers" do
    let(:header) {{ "Content-Type" => 'MuLtIpArT/rElAtEd; boundary="--==_mimepart_4d416ae62fd32_201a8043814c4724"; charset=UTF-8; type="text/xml"' }}
    let(:path) { File.expand_path('../../../fixtures/response/simple_multipart.txt', __FILE__) }

    it "does not care about upper or lowercase values for ContentType" do
      expect(response.body).to eq({:submit_req => true})
    end
  end

  context "not multipart" do
    let(:path) { File.expand_path('../../../fixtures/response/not_multipart.txt', __FILE__) }
    let(:header) { { 'Content-Type' => 'text/html; charset=utf-8'} }

    it "parses soap messages without attachments too" do
      expect(response.xml.chomp).to eq('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:wsdl="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header><ns1:TransactionID soapenv:actor="" soapenv:mustUnderstand="1" xsi:type="xsd:string" xmlns:ns1="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2">2011012713535811111111111</ns1:TransactionID></soapenv:Header><soapenv:Body><SubmitReq xmlns="http://www.3gpp.org/ftp/Specs/archive/23_series/23.140/schema/REL-5-MM7-1-2"><MM7Version>5.3.0</MM7Version><SenderIdentification><VASPID>messaging</VASPID><VASID>ADM</VASID><SenderAddress><ShortCode>1111</ShortCode></SenderAddress></SenderIdentification><Recipients><To><Number>11111111111</Number></To></Recipients><ServiceCode>1</ServiceCode><MessageClass>Personal</MessageClass><ExpiryDate>2011-01-28T13:53:58Z</ExpiryDate><DeliveryReport>false</DeliveryReport><ReadReply>false</ReadReply><Priority>Normal</Priority><Subject>Test MMS via Savon</Subject><ChargedParty>Sender</ChargedParty><Content href="cid:attachment_1" allowAdaptations="true"/></SubmitReq></soapenv:Body></soapenv:Envelope>')
      expect(response.parts.size).to eq(0)
      expect(response.attachments.size).to eq(0)
    end
  end

  context "soap errors" do
    let(:path) { File.expand_path('../../../fixtures/response/soap_fault.txt', __FILE__) }

    it "handles them correctly" do
      expect { response }.to raise_error(Savon::SOAPFault, /The service cannot be found/)
    end
  end
end
