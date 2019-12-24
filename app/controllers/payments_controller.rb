# frozen_string_literal: true

class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: [:callback]

  def index
    @sales = Sale.where(user_id: current_user.id)
    respond_to do |format|
      format.html
    end
  end

  def create_qr_payment
    price = 0.01
    total = price * params[:quantity].to_i
    reference_id = rand(100..1_000_000)
    @sale = Sale.create(reference_id: reference_id.to_s, quantity: params[:quantity].to_i, price: price, total: total, user_id: current_user.id, status: 'pending')
    uri = URI.parse('https://appws.picpay.com/ecommerce/public/payments')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request['X-Picpay-Token'] = ENV['X-Picpay-Token']
    request.body = JSON.dump(
      'referenceId' => reference_id.to_s,
      'callbackUrl' => "#{ENV['host_url']}/payments/callback",
      'returnUrl' => "#{ENV['host_url']}",
      'value' => total,
      'expiresAt' => '2022-05-01T16:00:00-03:00',
      'buyer' => {
        'firstName' => current_user.first_name.to_s,
        'lastName' => current_user.last_name.to_s,
        'document' => current_user.cpf.to_s,
        'email' => current_user.email.to_s,
        'phone' => current_user.phone.to_s
      }
    )

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    response.code
    response.body
    response = JSON.parse(response.body)
    redirect_to response['paymentUrl']
  end

  def callback
    uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments/#{params['referenceId']}/status")
    @sale = Sale.where(reference_id: params['referenceId']).first
    request = Net::HTTP::Get.new(uri)
    request.content_type = 'application/json'
    request['X-Picpay-Token'] = ENV['X-Picpay-Token']

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    response = JSON.parse(response.body)
    @sale.update(status: response['status'])
    create_histories if response['status'] == 'paid'
  end

  private

  def payment_params
    params.require(:pic_pay_payment)
          .permit(:quantity)
  end

  def create_histories
    (1..@sale.quantity).each do |i|
      history = History.create(title: "Pedido - #{@sale.reference_id} - Historia número #{i}", user_id: @sale.user_id)
      Link.create(id: history.id, url: "#{ENV['host_url']}histories/#{history.id}")
    end
  end
end
