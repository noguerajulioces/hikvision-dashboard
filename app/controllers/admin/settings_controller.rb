module Admin
  class SettingsController < ApplicationController
    def show
      @keys = %i[
        hourly_rate
        overtime_rate
        margin_of_tolerance
        lunch_hours
        hr_manager_name
        hr_manager_title
        admin_manager_name
        admin_manager_title
      ]

      @settings = @keys.index_with { |key| AppSetting[key] }
    end

    def update
      @keys = setting_params.keys.map(&:to_sym)

      @keys.each do |key|
        value = setting_params[key]
        value = value.gsub(".", "") if %w[hourly_rate overtime_rate].include?(key.to_s)
        AppSetting[key] = value
      end

      redirect_to admin_settings_path, notice: "Configuraciones actualizadas correctamente."
    end

    private

    def setting_params
      params.require(:settings).permit(
        :hourly_rate, :overtime_rate,
        :margin_of_tolerance, :lunch_hours,
        :hr_manager_name, :hr_manager_title,
        :admin_manager_name, :admin_manager_title
      )
    end
  end
end
