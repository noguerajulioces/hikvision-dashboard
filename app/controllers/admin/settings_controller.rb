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

      ActiveRecord::Base.transaction do
        @keys.each do |key|
          value = setting_params[key]
          # Clean numeric values
          value = value.gsub(".", "") if %w[hourly_rate overtime_rate].include?(key.to_s)
          
          # Use raw SQL to bypass the Paranoia gem's conditions
          setting = AppSetting.unscoped.find_by(key: key.to_s)
          
          if setting
            # Update existing setting
            setting.update_column(:value, value)
          else
            # Create new setting with direct SQL to avoid Paranoia
            AppSetting.connection.execute(
              "INSERT INTO app_settings (key, value, created_at, updated_at) VALUES ('#{key}', '#{value}', NOW(), NOW())"
            )
          end
        end
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
