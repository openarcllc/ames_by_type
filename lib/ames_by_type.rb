module ActiveModel
  class Errors
    attr_reader :messages_by_type

    def initialize(base)
      @base = base
      @messages = {}
      @messages_by_type = {}
    end

    def add(attribute, message = :invalid, options = {})
      normalized_message = normalize_message(attribute, message, options)
      if exception = options[:strict]
        exception = ActiveModel::StrictValidationFailed if exception == true
        raise exception, full_message(attribute, message)
      end

      if message.is_a?(Symbol)
        message_by_type = {}
        message_by_type[message] = normalized_message
        self.messages_by_type[attribute] = (self.messages_by_type[attribute] || {}).merge(message_by_type)
      end
      
      self[attribute] = normalized_message
    end

    def by_type(full_messages: false)
      return messages_by_type.dup unless full_messages
      messages_by_type.each do |attribute, messages|
        messages.each do |type, message|
          messages_by_type[attribute][type] = full_message(attribute, message)
        end
      end
    end
  end
end
