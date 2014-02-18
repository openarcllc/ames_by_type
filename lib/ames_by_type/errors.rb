ActiveModel::Errors.class_eval do
  attr_reader :messages_by_type

  def initialize(base)
    @base = base
    @messages = {}
    @messages_by_type = {}
  end
    
  # If the provided message is a symbol, it is treated as a type.
  # The +messages_by_type+ hash includes a key for each attribute
  # (like +messages+), where the corresponding values are error
  # messages organized (in hash form) by validation types.
  # 
  #   giraffe.errors.add(:name, :blank)
  #   giraffe.errors.add(:name, :too_short, count: 1)
  #   giraffe.errors.messages_by_type
  #   # => { name: { blank: "can't be blank",
  #                  too_short: "is too short (minimum is 1 character)"
  #                }}
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

  # Returns +messages_by_type+ (outlined above). Accepts a +full_message+
  # keyword argument. When +true+, full messages are included. 
  #
  #   zebra.errors.add(:name, :blank)
  #   zebra.errors.by_type
  #   # => { name: { blank: "can't be blank" }}
  #   zebra.errors.by_type(full_messages: true)
  #   # => { name: { blank: "Name can't be blank" }}
  def by_type(full_messages: false)
    return messages_by_type.dup unless full_messages
    messages_by_type.each do |attribute, messages|
      messages.each do |type, message|
        messages_by_type[attribute][type] = full_message(attribute, message)
      end
    end
  end
end
