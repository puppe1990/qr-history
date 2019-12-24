# frozen_string_literal: true

class History < ApplicationRecord
  has_rich_text :content
end
