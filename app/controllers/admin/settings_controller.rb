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

          # Upsert WITHOUT running model validations, matching the original intent.
          # AppSetting defines a class-level method_missing + respond_to_missing?
          # that returns true for everything, which corrupts ActiveRecord's
          # validation introspection (the uniqueness check builds an invalid query).
          # update_column / insert both skip validations and callbacks, and are
          # database-agnostic (the previous raw INSERT used NOW(), unsupported by SQLite).
          setting = AppSetting.find_by(key: key.to_s)
          if setting
            setting.update_column(:value, value)
          else
            now = Time.current
            AppSetting.insert({ key: key.to_s, value: value, created_at: now, updated_at: now })
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
