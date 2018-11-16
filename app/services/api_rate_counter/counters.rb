class APIRateCounter
  class Counters
    attr_reader :counters

    def initialize
      @counters = {}
    end

    def get_or_add(api_name:, discriminator:, **options)
      key = self.key(api_name, discriminator)
      counters[key] ||= APIRateCounter.new(api_name: api_name, discriminator: discriminator, **options)
    end

    def get(api_name:, discriminator:)
      key = self.key(api_name, discriminator)
      counters[key]
    end

    def clear
      @counters = {}
    end

    def key(api_name, discriminator)
      "#{api_name}:#{discriminator}"
    end
  end
end
