class DevicesController < ApplicationController
  before_action :set_device, only: [ :show, :edit, :update, :destroy ]

  # GET /devices
  def index
    @devices = Device.page(params[:page])
  end

  # GET /devices/1
  def show
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  def create
    @device = Device.new(device_params)

    if @device.save
      redirect_to @device, notice: "Dispositivo creado exitosamente."
    else
      render :new
    end
  end

  # PATCH/PUT /devices/1
  def update
    if @device.update(device_params)
      redirect_to @device, notice: "Dispositivo actualizado exitosamente."
    else
      render :edit
    end
  end

  # DELETE /devices/1
  def destroy
    @device.destroy
    redirect_to devices_url, notice: "Dispositivo eliminado exitosamente."
  end

  private
    # Use callbacks to share common setup or constraints between actions
    def set_device
      @device = Device.find(params[:id])
    end

    # Only allow a list of trusted parameters through
    def device_params
      params.require(:device).permit(:name, :ip_address, :model)
    end
end
