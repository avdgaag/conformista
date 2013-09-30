module Conformista
  module Presenting
    def presents(*args)
      if args.size == 1
        present_models *args
      else
        present_model *args
      end
    end

    def present_models(options = {})
      options.each do |model, attributes|
        present_model model, *attributes
      end
    end

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
