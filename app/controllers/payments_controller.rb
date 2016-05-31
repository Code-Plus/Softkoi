class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show]
  load_and_authorize_resource

  def index
    # @payments = Payment.distinct(:sale_id)
    @payments = Payment.all
  end

  def show
  end

  def generate_sale_pdf
    @pay_amount = 0
		@sale_to_pdf = params[:param1].to_i
		@payment_to_pdf = params[:param2].to_i
		@detail_sale = Item.where(sale_id: @sale_to_pdf)
		@user_do_payment = current_user.name
		@sale_to_pdf = Sale.where(id: @sale_to_pdf)
		@payment_to_pdf = Payment.where(id: @payment_to_pdf)
    all_payments = Payment.where(sale_id: @sale_to_pdf)
		@sale_to_pdf.each do |sale|
			@sale_id = sale.id
			@sale_amount = sale.amount
			if sale.discount.nil?
				@sale_discount = 0
			else
				@sale_discount = sale.amount * sale.discount
			end
      @sale_limit_date = sale.limit_date
			@sale_total_amount = sale.total_amount
      @sale_customer = sale.customer.name
		end
    all_payments.each do |pay|
      @pay_amount += pay.amount
    end
		respond_to do |format|
			format.js
			format.pdf do
				pdf=PaymentPdf.new(@sale_to_pdf,@detail_sale,@payment_to_pdf,@user_do_payment,@sale_id,@sale_limit_date,@sale_amount,@sale_discount,@sale_total_amount,@pay_amount,@sale_customer)
				send_data pdf.render, filename: 'pago.pdf',:disposition => "inline",type: 'application/pdf'
			end
		end
	end

  def make_payment
    @sale = Sale.find(params[:payments][:sale_id])
    payment_create = Payment.create(amount: params[:payments][:amount], sale_id: params[:payments][:sale_id])
    respond_to do |format|
      format.html{redirect_to url_for(:controller => :payments ,format: :pdf ,:action => :generate_sale_pdf, :param1 => @sale, :param2 =>payment_create)}
    end
  end

  def new
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(payment_params)

    respond_to do |format|
      if @payment.save
        format.html { redirect_to @payment, notice: 'Payment was successfully created.' }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end



  private

    def set_payment
      @payment = Payment.find(params[:id])
    end

    def payment_params
      params.require(:payment).permit(:amount, :sale_id)
    end
end
