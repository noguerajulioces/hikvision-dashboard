module ApplicationHelper
  def paginated_index(collection, index)
    (collection.current_page - 1) * collection.per_page + index
  end
end
