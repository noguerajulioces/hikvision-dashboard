class EmployeesController < ApplicationController
  before_action :set_employee, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = Employee.ransack(params[:q])
    @employees = @q.result.paginate(page: params[:page], per_page: 10)
  end

  def show
    @employee = Employee.find(params[:id])

    @attendance_records = @employee.attendance_records.paginate(page: params[:attendance_page], per_page: 10)
    @overtime_records = @employee.overtime_records.paginate(page: params[:overtime_page], per_page: 10)
    @events = @employee.events.paginate(page: params[:events_page], per_page: 10)
    @incidents = @employee.incidents.paginate(page: params[:incidents_page], per_page: 10)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
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
    params.require(:employee).permit(:first_name, :last_name, :email, :phone, :hire_date, :termination_date, :group_id, :document_number)
  end
end
