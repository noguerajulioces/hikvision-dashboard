module Admin
  class SettingsController < ApplicationController
    def create
      @errors = ActiveModel::Errors.new(Setting)
      setting_params.keys.each do |key|
        next if setting_params[key].nil?

        setting = Setting.new(var: key)
        # Remove dots from numeric values before validation
        value = setting_params[key].strip
        value = value.gsub(".", "") if [ "hourly_rate", "overtime_rate" ].include?(key)
        setting.value = value

        unless setting.valid?
          @errors.merge!(setting.errors)
        end
      end

      if @errors.any?
        render :new
      end

      setting_params.keys.each do |key|
        value = setting_params[key].strip
        value = value.gsub(".", "") if [ "hourly_rate", "overtime_rate" ].include?(key)
        Setting.send("#{key}=", value) unless setting_params[key].nil?
      end

      redirect_to admin_settings_path, notice: "La configuración se actualizó correctamente."
    end

    private
      def setting_params
        params.require(:setting).permit(:hourly_rate, :overtime_rate, :margin_of_tolerance, :lunch_hours, :hr_manager_name, :hr_manager_title, :admin_manager_name, :admin_manager_title)
      end
  end
end
