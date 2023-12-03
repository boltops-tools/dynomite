module Dynomite
  module Associations
    class HasAndBelongsToMany
      include ManyAssociation

      private

      # Find the target association, always another :has_and_belongs_to_many association. Uses either options[:inverse_of] or the source class name
      # and default parsing to return the most likely name for the target association.
      def target_association
        key_name = options[:inverse_of] || source.class.to_s.pluralize.underscore.to_sym
        guess = target_class.associations[key_name]
        return nil if guess.nil? || guess[:type] != :has_and_belongs_to_many

        association_method_name(key_name)
      end
    end
  end
end
