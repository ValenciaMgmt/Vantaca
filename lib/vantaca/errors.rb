# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

module Vantaca
  module Errors
    # The base error class which more specific API error classes inherit from.
    class ApiError < ::RuntimeError
      DEFAULT_MESSAGE = 'An unknown error occurred.'

      def initialize(response = nil)
        @response = response

        super()
      end

      def to_s
        return self.class::DEFAULT_MESSAGE unless @response

        format(
          '%<code>s: %<message>s (%<uri>s)',
          code: @response.code,
          # Vantaca doesn't put the error message in the response body - it's in the status header!
          message: @response.response.message,
          uri: filtered_uri
        )
      end

      def filtered_uri = @response.request.last_uri.to_s.gsub(/(company|login|pwd)=(?:[a-z0-9]+)/i, '\1=[FILTERED]')
    end

    # The client submitted invalid information.
    class ClientError < ApiError
      DEFAULT_MESSAGE = 'An unknown client error occurred.'
    end

    # A request was made for a key/query that doesn't exist.
    class NotFoundError < ClientError
      DEFAULT_MESSAGE = 'The requested resource could not be found.'
    end

    # Something happened but we don't know what and it's probably not our fault.
    class InternalError < ApiError
      DEFAULT_MESSAGE = 'An unknown internal error occurred.'
    end

    # The API took too long to respond, but everything might be fine later.
    class TimeoutError < InternalError
      DEFAULT_MESSAGE = 'The request timed out. Please try again in a moment.'
    end
  end
end
