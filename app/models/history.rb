# frozen_string_literal: true

class History < ApplicationRecord
  has_rich_text :content
  require 'rqrcode'
  require 'rqrcode_png'

  def generate_qrcode
    qrcode = RQRCode::QRCode.new(self.short)
  end
end
