class EventsController < ApplicationController
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]

  # GET /events
  def index
    @q = Event.ransack(params[:q])
    @events = @q.result.paginate(page: params[:page])
  end

  # GET /events/1
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to @event, notice: "Evento creado exitosamente."
    else
      render :new
    end
  end

  # POST /events/import
  def import
    if params[:file].present?
      EventImportService.new(params[:file].path).call
      redirect_to events_path, notice: "Eventos importados exitosamente."
    else
      redirect_to events_path, alert: "Por favor seleccione un archivo para importar."
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Evento actualizado exitosamente."
    else
      render :edit
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    redirect_to events_url, notice: "Evento eliminado exitosamente."
  end

  private
    # Use callbacks to share common setup or constraints between actions
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through
    def event_params
      params.require(:event).permit(:s_name, :s_job_no, :s_card, :date, :time,
                                  :in_out, :read_id, :event_main_code, :event_sub_code,
                                  :attendance_status, :wear_mask, :serial_no)
    end
end
