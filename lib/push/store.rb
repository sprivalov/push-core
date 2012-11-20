module ActiveRecord
  module Store
    extend ActiveSupport::Concern

    module ClassMethods
      def store(store_attribute, options = {})
        serialize store_attribute, Hash
        store_accessor(store_attribute, options[:accessors]) if options.has_key? :accessors
      end

      def store_accessor(store_attribute, *keys)
        Array(keys).flatten.each do |key|
          define_method("#{key}=") do |value|
            send("#{store_attribute}=", {}) unless send(store_attribute).is_a?(Hash)
            send(store_attribute)[key] = value
            send("#{store_attribute}_will_change!")
          end

          define_method(key) do
            send("#{store_attribute}=", {}) unless send(store_attribute).is_a?(Hash)
            send(store_attribute)[key]
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::Store
end
