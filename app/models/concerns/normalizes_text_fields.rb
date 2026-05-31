module NormalizesTextFields
  extend ActiveSupport::Concern

  class_methods do
    def normalizes_text_fields(*field_names)
      before_validation do
        field_names.each do |field_name|
          value = public_send(field_name)
          next if value.nil?

          public_send("#{field_name}=", normalize_text_value(value))
        end
      end
    end
  end

  private

  def normalize_text_value(value)
    value.to_s.downcase.gsub(/\s+/, "").gsub("test", "")
  end
end
