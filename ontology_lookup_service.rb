# frozen_string_literal: true

require 'socket'
require 'open-uri'
require 'json'

# Enums to represent http status codes.
module HttpStatusCode
  SERVICE_UNAVAILABLE = 503
  INTERNAL_SERVER_ERROR = 500
  NOT_FOUND = 404
end

# This class is used to get details about an ontology.
class OntologyLookupService
  def initialize(ontology_id)
    @ontology_id = ontology_id
  end

  def fetch_details
    ontology_lookup_url = 'http://www.ebi.ac.uk/ols/api/ontologies/%<ontology_id>s'
    ext_response = open(format(ontology_lookup_url, ontology_id: @ontology_id))
    form_response JSON.parse(ext_response.read)
  rescue OpenURI::HTTPError => e
    form_error e.io.status[0].to_i
  # N/w is unreqchable due to connectivity (No internet connection).
  rescue SocketError
    form_error HttpStatusCode::INTERNAL_SERVER_ERROR
  rescue StandardError
    # Some other unexpected error has occurred. A logger can be added for
    # debugging purpose.
    form_error HttpStatusCode::INTERNAL_SERVER_ERROR
  end

  # Form the required response structure from external api response.
  def form_response(ext_response)
    {
      title: ext_response['config']['title'],
      description: ext_response['config']['description'],
      numberOfTerms: ext_response['numberOfTerms'],
      status: ext_response['status']
    }
  end

  # Form the error resposne from external api error response.
  # Errors are stored in this method for simplicity, if there are a large no. of
  # errors it should be moved to a new file dedicated to errors and referred here.
  def form_error(http_status_code) # rubocop:disable Metrics/MethodLength
    errors = {
      HttpStatusCode::NOT_FOUND => {
        # Unique id for the error message.
        id: '1',
        status: HttpStatusCode::NOT_FOUND,
        error: 'Unable to get details of ontology with given id.'
      },
      HttpStatusCode::SERVICE_UNAVAILABLE => {
        id: '2',
        status: HttpStatusCode::SERVICE_UNAVAILABLE,
        error: 'The service is temporarily unavailable, please check later.'
      },
      HttpStatusCode::INTERNAL_SERVER_ERROR => {
        id: '3',
        status: HttpStatusCode::INTERNAL_SERVER_ERROR,
        error: 'Something unexpected happened please contact administrator.'
      }
    }

    return errors[http_status_code] if errors.key?(http_status_code)

    # Returning `internal server error` if no specific error is found. Cause needs to be
    # investigated from backend.
    errors[HttpStatusCode::INTERNAL_SERVER_ERROR]
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts 'Too few arguments. Expects one argument `ontology-id`'
    exit
  elsif ARGV.length > 1
    puts 'Too many arguments. Expects one argument `ontology-id`'
    exit
  end

  puts OntologyLookupService.new(ARGV[0]).fetch_details.to_json
end
