module ApplicationHelper
  def paginated_index(collection, index)
    (collection.current_page - 1) * collection.per_page + index
  end

  def format_hours_to_human_readable(total_hours)
    return "0 horas" if total_hours.nil? || total_hours.zero?

    hours = total_hours.to_i
    minutes = ((total_hours - hours) * 60).round

    if minutes.zero?
      "#{hours} horas"
    elsif hours.zero?
      "#{minutes} minutos"
    else
      "#{hours} horas y #{minutes} minutos"
    end
  end

  def lunch_inclusion_label(schedule)
    schedule.include_lunch ? "Incluye" : "No incluye"
  end
end
