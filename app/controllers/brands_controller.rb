class BrandsController < BaseController
  def update
    brand = Brand.find(params[:id])

    if brand.update(brand_params)
      render json: {
        id: brand.id,
        name: brand.name,
        users_count: brand.users_count
      }
    else
      render json: { errors: brand.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def brand_params
    params.require(:brand).permit(:name)
  end
end
