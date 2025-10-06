class ServicesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if params[:query].present?
      multisearch_results = PgSearch.multisearch(params[:query])
      @services = multisearch_results
                       .where(searchable_type: "Service")
                       .map(&:searchable)
    elsif params[:mode] == "filtros"
      @services = Service.filter(params)
    else
      @services = Service.all
    end
  end

  def show
    @order = Order.new
    @service = Service.find(params[:id])
  end

end
