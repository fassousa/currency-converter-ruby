# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Currency Converter API',
        version: 'v1',
        description: 'A RESTful API for currency conversion with real-time exchange rates. ' \
                     'Supports BRL, USD, EUR, and JPY currencies with secure JWT authentication.',
        contact: {
          name: 'API Support',
          url: 'https://github.com/fassousa/currency-converter-ruby',
        },
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server',
        },
        {
          url: 'https://{defaultHost}',
          description: 'Production server',
          variables: {
            defaultHost: {
              default: 'api.currencyconverter.com',
            },
          },
        },
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT token obtained from /api/v1/auth/sign_in endpoint',
          },
        },
        schemas: {
          ErrorResponse: {
            type: :object,
            properties: {
              error: {
                type: :object,
                properties: {
                  type: { type: :string, example: 'validation_error' },
                  message: { type: :string, example: 'Invalid parameters' },
                  details: { type: :object },
                },
              },
            },
          },
        },
      },
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
