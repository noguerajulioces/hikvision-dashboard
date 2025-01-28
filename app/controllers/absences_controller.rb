class AbsencesController < ApplicationController
  before_action :set_absence, only: [ :show, :edit, :update, :destroy ]

  # GET /absences
  def index
    @absences = Absence.paginate(page: params[:page])
  end

  # GET /absences/1
  def show
  end

  # GET /absences/new
  def new
    @absence = Absence.new
  end

  # GET /absences/1/edit
  def edit
  end

  # POST /absences
  def create
    @absence = Absence.new(absence_params)

    if @absence.save
      redirect_to @absence, notice: "La ausencia fue creada exitosamente."
    else
      render :new
    end
  end

  # PATCH/PUT /absences/1
  def update
    if @absence.update(absence_params)
      redirect_to @absence, notice: "La ausencia fue actualizada exitosamente."
    else
      render :edit
    end
  end

  # DELETE /absences/1
  def destroy
    @absence.destroy
    redirect_to absences_url, notice: "La ausencia fue eliminada exitosamente."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_absence
    @absence = Absence.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def absence_params
    params.require(:absence).permit(:start_date, :end_date, :absence_type, :employee_id)
  end
end
