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
        return nil unless key[/^trocla_lookup::/] or key[/^trocla_hierarchy::/]

        method, format, trocla_key = key.split('::', 3)

        case method
        when 'trocla_lookup'
          trocla_lookup(trocla_key, format, scope, order_override)
        when 'trocla_hierarchy'
          trocla_hierarchy(trocla_key, format, scope, order_override)
        end
      end

      # This is a simple lookup which will return a password for the key
      def trocla_lookup(trocla_key, format, scope, order_override)
        opts = options(trocla_key, format, scope, order_override)
        @trocla.password(opts.delete('trocla_key')||trocla_key, format, opts)
      end

      def trocla_hierarchy(trocla_key, format, scope, order_override)
        opts = options(trocla_key, format, scope, order_override)
        tk = opts.delete('trocla_key') || trocla_key
        get_password_from_hierarchy(tk, format, opts, scope, order_override) ||
          set_password_in_hierarchy(tk, format, opts, scope, order_override)
      end

      # Try to retrieve a password from a hierarchy
      def get_password_from_hierarchy(trocla_key, format, opts, scope, order_override)
        answer = nil
        Backend.datasources(scope, order_override) do |source|
          key = hierarchical_key(source, trocla_key)
          answer = @trocla.get_password(key, format, opts)
          break unless answer.nil?
        end
        return answer
      end

      # Set the password in the hierarchy at the top level or whatever
      # level is specified in the options hash with 'order_override'
      def set_password_in_hierarchy(trocla_key, format, opts, scope, order_override)
        answer = nil
        Backend.datasources(scope, opts['order_override']) do |source|
          key = hierarchical_key(source, trocla_key)
          answer = @trocla.password(key, format, opts)
          break unless answer.nil?
        end
        return answer
      end

      def hierarchical_key(source, trocla_key)
        "hiera/#{source}/#{trocla_key}"
      end

      # returns global options for password generation
      def global_options(format, scope, order_override)
        g_options = Backend.lookup('trocla_options', {}, scope, order_override, :hash)
        g_options.merge(g_options[format] || {})
      end

      # returns per key options for password generation
      def key_options(trocla_key, format, scope, order_override)
        k_options = Backend.lookup('trocla_options::' + trocla_key, {}, scope, order_override, :hash)
        k_options.merge(k_options[format] || {})
      end

      # retrieve options hash and merge the format specific settings into the defaults
      def options(trocla_key, format, scope, order_override)
        g_options = global_options(format, scope, order_override)
        k_options = key_options(trocla_key, format, scope, order_override)
        g_options.merge(k_options)
      end

    end
  end
end
