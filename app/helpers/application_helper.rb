module ApplicationHelper
  def paginated_index(collection, index)
    (collection.current_page - 1) * collection.per_page + index
  end

  def format_hours_to_human_readable(total_hours)
    numeric_hours = total_hours.to_f
    return "0 horas" if numeric_hours <= 0

    hours = total_hours.to_i
    minutes = ((total_hours - hours) * 60).round

    if hours.zero? && minutes.positive?
      "#{minutes} minutos"
    elsif minutes.zero?
      "#{hours} horas"
    else
      "#{hours} horas y #{minutes} minutos"
    end
  end

  def lunch_inclusion_label(schedule)
    return content_tag(:span, "-", class: "text-red-500") if schedule.nil?

    schedule.include_lunch ? "Incluye" : "No incluye"
  end
end
