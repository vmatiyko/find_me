module HomeHelper
  def brand_nav_link_class(brand, selected_brand)
    class_names(
      "list-group-item list-group-item-action",
      active: brand_selected?(brand, selected_brand)
    )
  end

  def brand_nav_badge_class(brand, selected_brand)
    brand_selected?(brand, selected_brand) ? "text-bg-light" : "text-bg-secondary"
  end

  def brand_nav_user_count_class(brand, selected_brand)
    brand_selected?(brand, selected_brand) ? "text-white-50" : "text-muted"
  end

  private

  def brand_selected?(brand, selected_brand)
    brand == selected_brand
  end
end
