class IncidentsController < ApplicationController
  before_action :set_incident, only: [ :show, :edit, :update, :destroy ]

  def index
    @incidents = Incident.all
  end

  def show
  end

  def new
    @incident = Incident.new
  end

  def create
    @incident = Incident.new(incident_params)
    if @incident.save
      redirect_to @incident, notice: "Incidente creado exitosamente."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @incident.update(incident_params)
      redirect_to @incident, notice: "Incidente actualizado exitosamente."
    else
      render :edit
    end
  end

  def destroy
    @incident.destroy
    redirect_to incidents_url, notice: "Incidente eliminado exitosamente."
  end

  private

  def set_incident
    @incident = Incident.find(params[:id])
  end

  def incident_params
    params.require(:incident).permit(:date, :issue, :resolved, :employee_id)
  end
end
