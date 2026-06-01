class UpdateBrand < Actor
  input :brand_id
  input :attributes

  output :brand

  def call
    self.brand = Brand.find(brand_id)

    fail!(error_messages: brand.errors.full_messages) unless brand.update(attributes)
  end
end
