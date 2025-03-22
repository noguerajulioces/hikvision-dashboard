class IncidentsController < ApplicationController
  before_action :set_incident, only: [ :show, :edit, :update, :destroy, :resolve ]

  def index
    @incidents = Incident.includes(:employee).paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
    @incident = Incident.new
    @incident.date = Date.today
  end

  def create
    @incident = Incident.new(incident_params)

    if @incident.save
      redirect_to incidents_path, notice: "Incidente creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @incident.update(incident_params)
      redirect_to incidents_path, notice: "Incidente actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @incident.destroy
    redirect_to incidents_path, notice: "Incidente eliminado exitosamente."
  end

  def resolve
    @incident.update(resolved: true)
    redirect_to incidents_path, notice: "Incidente marcado como resuelto."
  end

  private

  def set_incident
    @incident = Incident.find(params[:id])
  end

  def incident_params
    params.require(:incident).permit(:employee_id, :date, :issue, :resolved)
  end
end
