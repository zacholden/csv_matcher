# frozen_string_literal: true

# Wraps algo input, provides an interface to prevent
# string matching in mulitple places
class Algo
  def initialize(input)
    @input = input

    @email = true if input.include?('email')

    return unless input.include?('phone')

    @phone = true
  end

  def phone
    'phone'
  end

  def phone?
    @phone
  end

  def email
    'email'
  end

  def email?
    @email
  end
end
