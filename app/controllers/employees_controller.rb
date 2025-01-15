class EmployeesController < ApplicationController
  def search
    query = params[:query]
    employees = Employee.where("first_name LIKE ? OR last_name LIKE ?", "%#{query}%", "%#{query}%")
                        .where(group_id: nil)
    render json: employees.select(:id, :first_name, :last_name, :role)
  end
end
