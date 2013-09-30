module Conformista
  module Transactions
    def self.included(base)
      base.around_persist :wrap_in_database_transaction
    end

    def wrap_in_database_transaction
      ActiveRecord::Base.transaction do
        yield.tap do |all_saved|
          raise ActiveRecord::Rollback unless all_saved
        end
      end
    end
  end
end
