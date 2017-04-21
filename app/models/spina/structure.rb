module Spina
  class Structure < ApplicationRecord
    has_one :page_part, as: :page_partable
    has_many :structure_items

    accepts_nested_attributes_for :structure_items, allow_destroy: true#, reject_if: :no_item

    def no_item(attributes)
      logger.warn(attributes)
      return false
    end
    
    def content
      self
    end
  end
end
