class EmployeesController < ApplicationController
  def search
    query = params[:query]

    if query.blank?
      render json: []
      return
    end

    employees = Employee.where("first_name LIKE ? OR last_name LIKE ?", "%#{query}%", "%#{query}%")
                        .where(group_id: nil)
    render json: employees.select(:id, :first_name, :last_name, :role)
  end
end
