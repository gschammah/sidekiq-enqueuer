# frozen_string_literal: true

require "json"

module Sidekiq
  module Enqueuer
    module WebExtension
      # Turns the form's string inputs into perform arguments.
      #
      # Blank inputs are left out so the method default applies. A blank
      # positional input followed by a filled one is sent as nil, since
      # positions cannot be skipped. Filled inputs are coerced:
      #
      #   nil / null          -> nil
      #   true / false        -> true / false
      #   42, -7              -> Integer (no leading zeros, so "024" stays a String)
      #   1.5                 -> Float
      #   [..], {..}, ".."    -> parsed as JSON
      #   anything else       -> String
      class ParamsParser
        class Error < StandardError; end

        INTEGER = /\A-?(?:0|[1-9]\d*)\z/
        FLOAT = /\A-?(?:0|[1-9]\d*)\.\d+\z/
        JSON_START = /\A[\[{"]/

        Result = Struct.new(:args, :kwargs)

        attr_reader :raw_params, :worker

        def initialize(params, worker)
          @raw_params = params.is_a?(Hash) ? params : {}
          @worker = worker
        end

        def process
          args = []
          kwargs = {}
          pending_blanks = 0

          worker.params.each do |param|
            raw = raw_params[param.name.to_s].to_s.strip

            if raw.empty?
              raise Error, "#{param.name} is required" if param.required?

              pending_blanks += 1 unless param.keyword?
              next
            end

            value = coerce(param, raw)

            if param.keyword?
              kwargs[param.name.to_sym] = value
            else
              args.concat([nil] * pending_blanks)
              pending_blanks = 0
              args << value
            end
          end

          Result.new(args, kwargs)
        end

        private

        def coerce(param, raw)
          case raw
          when "nil", "null" then nil
          when "true" then true
          when "false" then false
          when INTEGER then Integer(raw, 10)
          when FLOAT then Float(raw)
          when JSON_START then parse_json(param, raw)
          else raw
          end
        end

        def parse_json(param, raw)
          JSON.parse(raw)
        rescue JSON::ParserError
          raise Error, "#{param.name} is not valid JSON: #{raw}"
        end
      end
    end
  end
end
