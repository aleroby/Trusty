class Suppliers::DashboardController < ApplicationController
  def index

    @supplier = current_user

    # Promedio global del proveedor (lo que recibe en cualquier servicio)
    @supplier_avg   = (@supplier.supplier_rating_avg || 0).round(2)
    @supplier_count = @supplier.supplier_reviews_count

  end
end
