require 'hiera/backend/trocla'
require 'trocla'

class Hiera
  module Backend
    class Trocla_backend

      def initialize
        Hiera.debug('Hiera Trocla backend starting')
        begin
          require 'trocla'
        rescue
          require 'rubygems'
          require 'trocla'
        end

        @trocla_conf = Config[:trocla] && Config[:trocla][:config]
        @trocla = ::Trocla.new(@trocla_conf)
      end

      def lookup(key, scope, order_override, resolution_type)
        # return immediately if this is no trocla lookup
        return nil unless key[/^trocla_lookup::/]

        _, format, trocla_key = key.split('::', 3)
        @trocla.password(trocla_key, format)
      end

    end
  end
end
