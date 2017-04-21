module Spina
  class StructurePart < ApplicationRecord
    include Part

    belongs_to :structure_item, optional: true
    belongs_to :structure_partable, polymorphic: true, optional: true, :autosave => true

    accepts_nested_attributes_for :structure_partable, allow_destroy: false

    def autosave_associated_records_for_structure_partable
      if structure_partable
        if self.name == 'keyword' && new_keyword = Spina::Keyword.where('name=?',structure_partable.name).first
        #if new_keyword = Spina::Keyword.where('id=? AND name=?',structure_partable.id,structure_partable.name).first
          self.structure_partable = new_keyword
        else
          structure_partable.save!
          self.structure_partable = structure_partable
          #self.structure_partable = Spina::Keyword.where('name=?',structure_partable.name).first
        end
      end
    end

    validates :structure_partable_type, presence: true
    validates :name, uniqueness: {scope: :structure_item_id}

    alias_attribute :partable, :structure_partable
    alias_attribute :partable_type, :structure_partable_type
    alias_method :structure_partable_attributes=, :partable_attributes=

    attr_reader :photo_tokens, :photo_positions
    def photo_tokens=(ids)
      self.photo_ids = ids.split(",")
    end

    def photo_positions=(positions)
      positions = positions.split(",")
      self.photo_collections_photos.each do |photo|
        photo.position = positions.index(photo.photo.try(:id).try(:to_s))
      end
      logger.info self.photo_collections_photos.inspect
    end
  end
end
