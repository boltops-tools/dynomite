module Dynomite
  # The base association module which all associations include. Every association has two very important components: the source and
  # the target. The source is the object which is calling the association information. It always has the target_ids inside of an attribute on itself.
  # The target is the object which is referencing by this association.
  module Associations
    module Association
      attr_accessor :name, :options, :source, :loaded

      # Create a new association.
      #
      # @param [Class] source the source record of the association; that is, the record that you already have
      # @param [Symbol] name the name of the association
      # @param [Hash] options optional parameters for the association
      # @option options [Class] :class the target class of the association; that is, the class to which the association objects belong
      # @option options [Symbol] :class_name the name of the target class of the association; only this or Class is necessary
      # @option options [Symbol] :inverse_of the name of the association on the target class
      # @option options [Symbol] :foreign_key the name of the field for belongs_to association
      #
      # @return [Dynomite::Association] the actual association instance itself
      def initialize(source, name, options)
        @source = source
        @name = name
        @options = options
        @loaded = false
      end

      def coerce_to_id(object)
        object.respond_to?(:partition_key) ? object.partition_key : object
      end

      def coerce_to_item(object)
        object.is_a?(String) ? target_class.find(object) : object
      end

      def loaded?
        @loaded
      end

      def find_target; end

      def target
        unless loaded?
          @target = find_target
          @loaded = true
        end

        @target
      end

      def reader_target
        self
      end

      def reset
        @target = nil
        @loaded = false
      end

      def declaration_field_name
        "#{name}_ids"
      end

      def declaration_field_type
        :set
      end

      private

      # The target class name, either inferred through the association's name or specified in options.
      def target_class_name
        options[:class_name] || name.to_s.classify
      end

      # The target class, either inferred through the association's name or specified in options.
      def target_class
        options[:class] || target_class_name.constantize
      end

      # The target attribute: that is, the attribute on each object of the association that should reference the source.
      def target_attribute
        # In simple case it's equivalent to
        # "#{target_association}_ids".to_sym if target_association
        if target_association
          target_options = target_class.associations[target_association]
          assoc = Dynomite::Associations.const_get(target_options[:type].to_s.camelcase).new(nil, target_association, target_options)
          assoc.send(:source_attribute)
        end
      end

      # The ids in the target association.
      def target_ids
        target.send(target_attribute) || Set.new
      end

      # The ids in the target association.
      def source_class
        source.class
      end

      # The source's association attribute: the name of the association with _ids afterwards, like "users_ids".
      def source_attribute
        declaration_field_name.to_sym
      end

      # The ids in the source association.
      def source_ids
        # handle case when we store scalar value instead of collection (when foreign_key option is specified)
        Array(source.send(source_attribute)).compact.to_set || Set.new
      end

      # Create a new instance of the target class without trying to add it to the association. This creates a base, that caller can update before setting or adding it.
      #
      # @param attributes [Hash] attribute values for the new object
      #
      # @return [Dynomite::Item] the newly-created object
      def build(attributes = {})
        target_class.build(attributes)
      end

      def association_method_name(name)
        name = name.to_s.end_with?("_association") ? name : "#{name}_association"
        name.starts_with?("_") ? name : "_#{name}"
      end
    end
  end
end
