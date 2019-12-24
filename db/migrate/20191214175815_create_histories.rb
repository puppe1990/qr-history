# frozen_string_literal: true

class CreateHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :histories do |t|
      t.string :title

      t.timestamps
    end
  end
end
