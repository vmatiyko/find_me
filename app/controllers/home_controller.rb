class HomeController < BaseController
  skip_before_action :load_brand, only: :index

  def index
    default_brand = Brand.order(:id).first_or_create!(name: "default")
    @brand = params[:brand_id].present? ? Brand.find(params[:brand_id]) : default_brand
    @brands = Brand.order(:id)
    @brand_users = @brand.brand_users.includes(:user).order(:id)
    @settings = @brand.settings.includes(:user).order(:id)
    @new_user = User.new
  end
end
