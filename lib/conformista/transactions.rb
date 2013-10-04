module Conformista
  # Provides transactional functionality to form objects, wrapping persistence
  # operations in a database transaction to ensure either all presented models
  # are persisted, or none are.
  module Transactions
    def self.included(base)
      base.around_persist :wrap_in_database_transaction
    end

    private

    def wrap_in_database_transaction
      ActiveRecord::Base.transaction do
        yield.tap do |all_saved|
          raise ActiveRecord::Rollback unless all_saved
        end
      end
    end
  end
end
