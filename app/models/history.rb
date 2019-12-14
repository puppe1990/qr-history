class History < ApplicationRecord
  has_rich_text :content
  require 'rqrcode'
  require 'rqrcode_png'

  def generate_qrcode
    qrcode = RQRCode::QRCode.new("https://conte-sua-historia.herokuapp.com/histories/#{id}")
  end
end
