DeprecationWarningError = Class.new(StandardError)

module RaiseOnDeprecationWarning
  # Gems announce deprecations in plain warnings without a category, hence the match on the message.
  def warn(message, category: nil, **options)
    raise DeprecationWarningError, message if category == :deprecated || message.match?(/deprecat/i)

    super
  end
end

Warning[:deprecated] = true
Warning.singleton_class.prepend(RaiseOnDeprecationWarning)

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib")
require "minitest/autorun"
require "pdf/writer"
