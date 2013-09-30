module Conformista
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

    def persisted?
      presented_models.all? do |model|
        send(model.model_name.singular).persisted?
      end
    end

    def save
      run_callbacks :save do
        persist_models
      end
    end

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
