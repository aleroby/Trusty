class ReviewsController < ApplicationController
  before_action :set_order, only: [:new, :review_for_client]
  def new
    if params[:order_id]
      @review = Review.new
    else
      @service = Service.find(params[:service_id])
      @review = Review.new
    end
  end

  def create
    if params[:service_id]
      review_for_supplier
    elsif params[:order_id]
      review_for_client
    end
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def review_for_supplier
    @service = Service.find(params[:service_id])
    @review = Review.new(review_params)
    @review.service = @service
    @review.client = current_user
    @review.supplier = @service.user

    if @review.save
      redirect_to service_reviews_path(@review)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def review_for_client
    @order = Order.find(params[:order_id])
    @review = Review.new(review_params)
    @review.service = @order.service
    @review.supplier = current_user
    @review.client = @order.user

    if @review.save
      redirect_to order_reviews_path(@review)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def review_params
    params.require(:review).permit(:rating, :content)
  end
end
