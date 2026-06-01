class BrandsController < BaseController
  def update
    result = UpdateBrand.result(brand_id: params[:id], attributes: brand_params)

    if result.success?
      render json: result.brand.as_json(only: %i[id name users_count])
    else
      render json: { errors: result.error_messages }, status: :unprocessable_entity
    end
  end

  private

  def brand_params
    params.require(:brand).permit(:name)
  end
end
