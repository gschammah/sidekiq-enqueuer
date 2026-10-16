# frozen_string_literal: true

module Sidekiq
  module Enqueuer
    module Worker
      class Param
        KINDS = {
          req: "required",
          opt: "optional",
          keyreq: "required keyword",
          key: "optional keyword"
        }.freeze

        attr_reader :name, :kind

        def initialize(name, kind)
          @name = name
          @kind = kind
        end

        def label
          KINDS[kind]
        end

        def supported?
          KINDS.key?(kind)
        end

        def required?
          kind == :req || kind == :keyreq
        end

        def optional?
          !required?
        end

        def keyword?
          kind == :key || kind == :keyreq
        end
      end
    end
  end
end
