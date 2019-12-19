class PaymentsController < ApplicationController

  skip_before_action :verify_authenticity_token
  def index
    @sales = Sale.where(user_id: current_user.id)
    respond_to do |format|
      format.html
    end
  end

  def create_qr_payment
    price = 0.01
    total = price * params[:quantity].to_i
    @sale = Sale.create(quantity: params[:quantity].to_i, price: price, total: total, status: 'pending')
    uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["X-Picpay-Token"] = ENV["X-Picpay-Token"]
    request.body = JSON.dump({
      "referenceId" => (15 + @sale.id).to_s,
      "callbackUrl" => "#{ENV['host_url']}/callback",
      "returnUrl" => "#{ENV['host_url']}/histories/index",
      "value" => total,
      "expiresAt" => "2022-05-01T16:00:00-03:00",
      "buyer" => {
        "firstName" => current_user.first_name.to_s,
        "lastName" => current_user.last_name.to_s,
        "document" => current_user.cpf.to_s,
        "email" => current_user.email.to_s,
        "phone" => current_user.phone.to_s
      }
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    response.code
    response.body
    response = JSON.parse(response.body)
    redirect_to response["paymentUrl"]
  end

  def callback
    params["referenceId"]
    params["authorizationId"]
  end

  private

  def payment_params
    params.require(:pic_pay_payment)
          .permit(:quantity)
  end
end
