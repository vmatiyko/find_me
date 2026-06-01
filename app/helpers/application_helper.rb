module ApplicationHelper
  def flash_alert_class(type)
    case type.to_s
    when "notice"
      "alert-success"
    when "alert"
      "alert-danger"
    else
      "alert-info"
    end
  end
end
