class BrandUsersController < BaseController
  before_action :set_brand

  def create
    user = find_or_create_user
    @brand.brand_users.create!(user: user)

    redirect_to root_path(brand_id: @brand.id), notice: "User added", status: :see_other
  rescue ActiveRecord::RecordInvalid => e
    redirect_to root_path(brand_id: @brand.id), alert: e.record.errors.full_messages.to_sentence, status: :see_other
  end

  def destroy
    @brand.brand_users.find_by!(user_id: params[:id]).destroy!

    redirect_to root_path(brand_id: @brand.id), notice: "User removed", status: :see_other
  end

  private

  def set_brand
    @brand = Brand.find(params[:brand_id])
  end

  def find_or_create_user
    user = User.new(user_params)
    user.validate

    existing_user = User.find_by(email: user.email)
    return existing_user if existing_user && only_email_taken_error?(user)

    raise ActiveRecord::RecordInvalid.new(user) if user.errors.any?

    user.save!
    user
  end

  def only_email_taken_error?(user)
    user.errors.details.all? do |attribute, errors|
      attribute == :email && errors.all? { |error| error[:error] == :taken }
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
end
