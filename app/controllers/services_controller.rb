class ServicesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if params[:query].present?
      multisearch_results = PgSearch.multisearch(params[:query])
      @services = multisearch_results
                       .where(searchable_type: "Service")
                       .map(&:searchable)
    else
      @services = Service.all
    end
  end

  def show
    @service = Service.find(params[:id])
  end

end
