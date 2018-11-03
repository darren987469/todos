require 'csv'

module Formatter
  module V1
    class CSV
      def self.call(object, _env)
        objects = Array(object)
        return nil unless object.present?

        ::CSV.generate(headers: true) do |csv|
          headers = objects.first.as_json.keys
          csv << headers

          objects.each do |obj|
            csv << obj.as_json.values
          end
        end
      end
    end
  end
end
