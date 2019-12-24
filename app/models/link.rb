# frozen_string_literal: true

class Link < ActiveRecord::Base
  require 'rqrcode'
  require 'rqrcode_png'
  validates_presence_of :url
  validates :url, format: URI.regexp(%w[http https])
  validates_uniqueness_of :slug
  validates_length_of :url, within: 3..255, on: :create, message: 'too long'
  validates_length_of :slug, within: 3..255, on: :create, message: 'too long'

  # auto slug generation
  before_validation :generate_slug

  def generate_slug
    self.slug = SecureRandom.uuid[0..5] if slug.nil? || slug.empty?
    true
  end

  # fast access to the shortened link
  def short
    Rails.application.routes.url_helpers.short_url(slug: slug)
  end

  # the API
  def self.shorten(url, slug = '')
    link = Link.where(url: url, slug: slug).first
    return link.short if link

    link = Link.new(url: url, slug: slug)
    return link.short if link.save

    Link.shorten(url, slug + SecureRandom.uuid[0..2])
  end

  def generate_qrcode
    RQRCode::QRCode.new(short)
  end
end
