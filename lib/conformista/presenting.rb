module Conformista
  # Presenting provides the macro to extend a form object with the methods to
  # present models and to build, persist and validate them.
  #
  # Given a model `User`, you can override the following methods to customise
  # the default behaviour:
  #
  # * `build_user`: should return a new instance of the model
  # * `user`: should return the currently presented model instance
  # * `user=`: set the currently presented model instance
  # * `persist_user`: persist the current model instance
  # * `load_user_attributes`: get model attributes and store it in the form
  #   object
  # * `delegate_user_attributes`: set model attributes from the form object
  #   attributes
  # * `validate_user`: test if the model instance is valid
  #
  # @example Present a single model
  #   class SignupForm < Conformista::FormObject
  #     presents User, :email, :password
  #   end
  #
  # @example Present multiple models
  #   class SignupForm < Conformista::FormObject
  #     presents User    => %i[email password],
  #              Profile => %i[twitter github bio]
  #   end
  #
  # @see FormObject
  module Presenting
    # Convenience method to use either `present_models` or `present_model`,
    # based on the number of arguments passed in.
    #
    # @overload presents(model, *attributes)
    #   Present a single model and its attributes
    #   @param [Class] model
    #   @param [Symbol] method name
    # @overload presents(models)
    #   Present multiple models using a Hash of classes and attributes
    #   @param [Hash] models as keys, array of attributes as value
    def presents(*args)
      if args.size == 1
        present_models *args
      else
        present_model *args
      end
    end

    # Present multiple models using a Hash of classes and attributes
    #
    # @param [Hash] options models as keys, array of attributes as value
    def present_models(options = {})
      options.each do |model, attributes|
        present_model model, *attributes
      end
    end

    # Present a single model and its attributes
    #
    # @param [Class] model the class of object to present
    # @param [Symbol] attributes one or more attribute names
    def present_model(model, *attributes)
      model_name = model.model_name.singular
      ivar = :"@#{model_name}".to_sym

      mod = Module.new do
        attr_accessor *attributes

        define_method :presented_models do
          super().tap do |orig|
            orig << model unless orig.include? model
          end
        end

        define_method model_name do
          if instance_variable_get(ivar).nil?
            instance_variable_set ivar, send(:"build_#{model_name}")
          else
            instance_variable_get ivar
          end
        end

        define_method :"build_#{model_name}" do
          model.new
        end

        define_method :"#{model_name}=" do |obj|
          instance_variable_set(ivar, obj).tap do |obj|
            send :"load_#{model_name}_attributes"
          end
        end

        define_method :"load_#{model_name}_attributes" do
          attributes.each do |attribute|
            send("#{attribute}=", send(model_name).send("#{attribute}"))
          end
        end

        define_method :"delegate_#{model_name}_attributes" do
          attributes.each do |attribute|
            send(model_name).send("#{attribute}=", send(attribute))
          end
        end

        define_method :"validate_#{model_name}" do
          send(model_name).valid?
        end

        define_method :"persist_#{model_name}" do
          send(model_name).save
        end
      end

      include mod
    end
  end
end
