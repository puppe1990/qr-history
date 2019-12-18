class PaymentsController < ApplicationController

  skip_before_action :verify_authenticity_token
  def index
    respond_to do |format|
      format.html
    end
  end

  def create_qr_payment
    price = 0.01
    total = price * params[:quantity].to_i
    uri = URI.parse("https://appws.picpay.com/ecommerce/public/payments")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["X-Picpay-Token"] = ENV["X-Picpay-Token"]
    request.body = JSON.dump({
      "referenceId" => "10",
      "callbackUrl" => "#{request.host}/callback",
      "returnUrl" => "#{request.host}/histories/index",
      "value" => total,
      "expiresAt" => "2022-05-01T16:00:00-03:00",
      "buyer" => {
        "firstName" => "Matheus",
        "lastName" => "Puppe",
        "document" => "023.997.080-24",
        "email" => "matheus.puppe@gmail.com",
        "phone" => "+55 11 99559-7242"
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
