# frozen_string_literal: true

json.array! @histories, partial: 'histories/history', as: :history
