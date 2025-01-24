class GroupsController < ApplicationController
  before_action :set_group, only: [ :show, :edit, :update, :destroy, :remove_employee ]

  def index
    @groups = Group
                .left_joins(:employees)
                .select('groups.*, COUNT(employees.id) AS employees_count')
                .group('groups.id')
  end

  def show
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to groups_path, notice: "Función creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to groups_path, notice: "Función actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: "Función eliminado exitosamente."
  end

  def add_employee
    @group = Group.find(params[:id])
    employee = Employee.find(params[:employee_id])

    if employee.update(group: @group)
      render json: { success: true }, status: :ok
    else
      render json: { error: "No se pudo asociar el empleado." }, status: :unprocessable_entity
    end
  end

  def remove_employee
    @employee = Employee.find(params[:employee_id])

    if @group.employees.delete(@employee)
      render json: { success: true }, status: :ok
    else
      render json: { error: "Error desasociando el empleado" }, status: :unprocessable_entity
    end
  end


  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
