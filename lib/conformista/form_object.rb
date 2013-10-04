module Conformista
  # The FormObject is an ActiveModel-compliant object that knows how to present
  # multiple Ruby objects (usually descendents of ActiveRecord::Base) to the
  # view layer in an application. The form object is specifically designed to
  # work with Rails `form_for` helpers.
  #
  # The form object's responsibility is not too complex:
  #
  # * Provide accessors to presented models.
  # * Delegate selected attributes on the form object to the appropriate
  #   presented models.
  # * Delegate model validation and persistence.
  #
  # We can make the behaviour a little more complex by defining validations
  # specific to our form object. Validations that belong on presenters rather
  # than data models include:
  #
  # * Matching password confirmation
  # * Acceptance of terms and conditions
  #
  # In your `FormObject` subclass, you can override methods to customize the
  # default behaviour. The default behaviour includes:
  #
  # * models are built using the `new` method
  # * models are saved using the `save` method
  # * model attributes are set using accessor methods
  # * models are validated using the `valid?` method
  #
  # You can customise its behaviour by overriding methods. You can add new
  # behaviour by using callbacks (`:validation`, `:save` and `:persist`).
  #
  # @example Present multiple models and override some default behaviour
  #   class SignupForm < Conformista::FormObject
  #     presents account: %i[name],
  #                 user: %i[email password],
  #              profile: %i[twitter github bio]
  #
  #     private
  #
  #     def build_profile
  #       user.build_profile
  #     end
  #
  #     def persist_user
  #       user.save!
  #     end
  #   end
  class FormObject
    extend ActiveModel::Callbacks
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    define_model_callbacks :save, :persist
    before_save :delegate_attributes

    include Transactions
    include Validations
    extend Presenting

    def initialize(params = {})
      set_attributes(params)
    end

    # Whether all presented models are persisted.
    def persisted?
      presented_models.all? do |model|
        send(model.model_name.singular).persisted?
      end
    end

    # Persist all models, if they are all valid. This invokes
    # the `:save` hook.
    def save
      run_callbacks :save do
        persist_models
      end
    end

    # Delegate the hash of attributes to the presented models
    # and save the object.
    #
    # @see #save
    # @param [Hash] params
    def update_attributes(params)
      set_attributes(params)
      save
    end

    private

    def set_attributes(params)
      params.each do |attr, value|
        public_send :"#{attr}=", value
      end if params
    end

    def presented_models
      []
    end

    def delegate_attributes
      each_model do |record, name|
        send :"delegate_#{name}_attributes"
      end
    end

    def persist_models
      run_callbacks :persist do
        presented_models.inject(true) do |all_saved, model|
          record_saved = send :"persist_#{model.model_name.singular}"
          all_saved &&= record_saved
        end
      end
    end

    def each_model
      presented_models.each do |presented_model|
        name = presented_model.model_name.singular
        yield send(name), name
      end
    end
  end
end
