# frozen_string_literal: true

require 'savon-multipart'

RSpec.describe Savon::Multipart::Response do
  let(:multipart_content_type) do
    'multipart/related; boundary="--==_mimepart_4d416ae62fd32_201a8043814c4724"; ' \
      'charset=UTF-8; type="text/xml"'
  end
  let(:header) { { 'Content-Type' => multipart_content_type } }
  let(:body) { File.read(path) }
  let(:response) { soap_response(headers: header, body: body) }

  def soap_response(options = {})
    defaults = { code: 200, headers: {}, body: '' }
    response = defaults.merge options
    globals = {
      multipart: true,
      raise_errors: true,
      convert_response_tags_to: ->(tag) { Savon::StringUtils.snakecase(tag).to_sym }
    }
    http = HTTPI::Response.new(response[:code], response[:headers], response[:body])

    Savon::Multipart::Response.new(http, globals, {})
  end

  context 'multipart' do
    let(:path) { File.expand_path('../../fixtures/response/multipart.txt', __dir__) }

    it 'parses the SOAP envelope from the first MIME part' do
      expected = File.expand_path('../../fixtures/response/multipart_expected.xml', __dir__)
      expect(response.xml.strip).to eq(File.read(expected))
    end

    it 'exposes the top-level MIME parts' do
      expect(response.parts.length).to eq(2)
    end

    it 'exposes nested MIME parts' do
      expect(response.parts[1].parts.length).to eq(3)
    end

    it 'decodes attachment bodies' do
      expect(response.parts[1].parts[2].body.decoded.strip).to eq('This is a test message from Github')
    end

    it 'returns the attachments' do
      expect(response.attachments.size).to eq(1)
    end

    it 'only parses the SOAP body once' do
      # Referencing `response` here builds it (parsing the body a first time)
      # before the spy is installed, so no further parses may happen below.
      allow(response).to receive(:parse_body).and_call_original

      5.times do
        response.attachments
      end

      expect(response).not_to have_received(:parse_body)
    end
  end

  context 'simple multipart' do
    let(:path) { File.expand_path('../../fixtures/response/simple_multipart.txt', __dir__) }

    it 'returns a String from the #xml method' do
      expect(response.xml.class).to eq(String)
    end

    it 'returns a Hash from the #body method' do
      expect(response.body).to eq({ submit_req: true })
    end
  end

  context 'simple xop' do
    let(:path) { File.expand_path('../../fixtures/response/simple_xop.txt', __dir__) }

    it 'returns a String from the #xml method' do
      expect(response.xml.class).to eq(String)
    end

    it 'returns a Hash from the #body method, include xop data' do
      expect(response.body).to eq({ binary_data: Base64.encode64('BinaryDataGoesHere').chomp })
    end
  end

  describe 'a multipart response with case sensitive headers' do
    let(:multipart_content_type) do
      'MuLtIpArT/rElAtEd; boundary="--==_mimepart_4d416ae62fd32_201a8043814c4724"; ' \
        'charset=UTF-8; type="text/xml"'
    end
    let(:path) { File.expand_path('../../fixtures/response/simple_multipart.txt', __dir__) }

    it 'does not care about upper or lowercase values for ContentType' do
      expect(response.body).to eq({ submit_req: true })
    end
  end

  context 'not multipart' do
    let(:path) { File.expand_path('../../fixtures/response/not_multipart.txt', __dir__) }
    let(:header) { { 'Content-Type' => 'text/html; charset=utf-8' } }

    it 'parses soap messages without attachments too' do
      expected = File.expand_path('../../fixtures/response/not_multipart_expected.xml', __dir__)
      expect(response.xml.chomp).to eq(File.read(expected))
    end

    it 'has no parts' do
      expect(response.parts.size).to eq(0)
    end

    it 'has no attachments' do
      expect(response.attachments.size).to eq(0)
    end
  end

  context 'soap errors' do
    let(:path) { File.expand_path('../../fixtures/response/soap_fault.txt', __dir__) }

    it 'handles them correctly' do
      expect { response }.to raise_error(Savon::SOAPFault, /The service cannot be found/)
    end
  end
end
