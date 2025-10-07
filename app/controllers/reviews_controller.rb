class ReviewsController < ApplicationController
  before_action :set_order, only: [:new, :create]
  def new
    @review = Review.new
  end

  def create
    # raise
    if @order.user == current_user
      review_for_supplier
    else
      review_for_client
    end
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def review_for_supplier
    @review = Review.new(review_params)
    @review.service = @order.service
    @review.client = current_user
    @review.supplier = @order.service.user

    if @review.save
      redirect_to dashboard_index_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def review_for_client
    @review = Review.new(review_params)
    @review.service = @order.service
    @review.supplier = @order.service.user
    @review.client = @order.user

    if @review.save
      redirect_to suppliers_dashboard_index_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def review_params
    params.require(:review).permit(:rating, :content)
  end
end
