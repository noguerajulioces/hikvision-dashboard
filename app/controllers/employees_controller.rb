class EmployeesController < ApplicationController
  before_action :set_employee, only: [ :show, :edit, :update, :destroy ]

  def index
    @employees = Employee.all
  end

  def show
  end

  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to employees_path, notice: "Empleado creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @employee.update(employee_params)
      redirect_to employees_path, notice: "Empleado actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_path, notice: "Empleado eliminado exitosamente."
  end

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

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :role, :group_id)
  end
end
