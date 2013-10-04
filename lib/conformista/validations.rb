module Conformista
  # Adds validation behaviour to ActiveModel-compliant objects. This means that
  # objects this module is mixed into will only run `save` if it responds
  # positively to `valid?`.
  #
  # This model makes sure that all attributes are properly delegated before any
  # validations run, and copies any presented model errors to the host object.
  #
  # You can override how specific models are validated by overriding the
  # `validate_MODEL_NAME` method.
  module Validations
    def self.included(base)
      base.before_validation :delegate_attributes
      base.before_validation :validate_models
      base.before_validation :copy_validation_errors
      base.before_save :valid?
    end

    private

    def validate_models
      each_model do |record, name|
        send :"validate_#{name}"
      end
    end

    def copy_validation_errors
      each_model do |record, name|
        record.errors.each do |key, value|
          errors.add key, value
        end
      end
    end
  end

end
