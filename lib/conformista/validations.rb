module Conformista
  module Validations
    def self.included(base)
      base.before_validation :delegate_attributes
      base.before_validation :validate_models
      base.before_validation :copy_validation_errors
      base.before_save :valid?
    end

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
