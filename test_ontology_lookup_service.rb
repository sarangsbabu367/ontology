# frozen_string_literal: true

require 'json'
require 'test/unit'
require 'minitest/mock'
require './ontology_lookup_service'

# To mock io
class MockIo
  def initialize(status_code)
    @status_code = status_code
  end

  def status
    [@status_code.to_s]
  end
end

# To mock http error
class MockHTTPError < OpenURI::HTTPError
  attr_accessor :io

  def initialize(status_code)
    super('', nil)
    @io = MockIo.new(status_code)
  end
end

# To mock success response
class MockResponse
  def initialize(http_status = nil)
    @http_status = http_status
  end

  def read
    raise MockHTTPError, @http_status unless @http_status.nil?

    {
      ontologyId: 'agro',
      status: 'LOADED',
      numberOfTerms: 3736,
      config: {
        title: 'Agronomy Ontology',
        description: 'AgrO is an ontlogy for representing agronomic practices, techniques, variables and related entities'
      }
    }.to_json
  end
end

# For testing OntologyLookupService
class OntologyLookupServiceTest < Test::Unit::TestCase
  def test_success
    Kernel.send(:define_method, :open) do |*_arg|
      MockResponse.new
    end

    ontology_service = OntologyLookupService.new('agro')
    assert_equal ontology_service.fetch_details, { description: 'AgrO is an ontlogy for representing agronomic practices, techniques, variables and related entities',
                                                   numberOfTerms: 3736,
                                                   status: 'LOADED',
                                                   title: 'Agronomy Ontology' }
  end

  def test_not_found
    Kernel.send(:define_method, :open) do |*_arg|
      MockResponse.new(HttpStatusCode::NOT_FOUND)
    end

    ontology_service = OntologyLookupService.new('agross')
    error_response = ontology_service.fetch_details
    assert_equal error_response[:id], '1'
    assert_equal error_response[:status], HttpStatusCode::NOT_FOUND
  end

  def test_service_unavailable
    Kernel.send(:define_method, :open) do |*_arg|
      MockResponse.new(HttpStatusCode::SERVICE_UNAVAILABLE)
    end

    ontology_service = OntologyLookupService.new('agross')
    error_response = ontology_service.fetch_details
    assert_equal error_response[:id], '2'
    assert_equal error_response[:status], HttpStatusCode::SERVICE_UNAVAILABLE
  end

  def test_other_bad_response
    Kernel.send(:define_method, :open) do |*_arg|
      MockResponse.new(HttpStatusCode::INTERNAL_SERVER_ERROR)
    end

    ontology_service = OntologyLookupService.new('agross')
    error_response = ontology_service.fetch_details
    assert_equal error_response[:id], '3'
    assert_equal error_response[:status], HttpStatusCode::INTERNAL_SERVER_ERROR
  end

  def test_socket_error
    Kernel.send(:define_method, :open) do |*_arg|
      raise SocketError
    end

    ontology_service = OntologyLookupService.new('agross')
    error_response = ontology_service.fetch_details
    assert_equal error_response[:id], '3'
    assert_equal error_response[:status], HttpStatusCode::INTERNAL_SERVER_ERROR
  end

  def test_standard_error
    Kernel.send(:define_method, :open) do |*_arg|
      raise StandardError
    end

    ontology_service = OntologyLookupService.new('agross')
    error_response = ontology_service.fetch_details
    assert_equal error_response[:id], '3'
    assert_equal error_response[:status], HttpStatusCode::INTERNAL_SERVER_ERROR
  end
end
