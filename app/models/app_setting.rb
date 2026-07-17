# == Schema Information
#
# Table name: app_settings
#
#  id         :integer          not null, primary key
#  key        :string
#  value      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# app/models/AppSetting.rb
class AppSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # Métodos de clase
  def self.[](key)
    value = find_by(key: key.to_s)&.value
    auto_convert_value(key, value)
  end

  def self.[]=(key, value)
    record = find_or_initialize_by(key: key.to_s)
    record.value = value
    record.save!
  end

  # Support for dot notation access (AppSetting.lunch_hours)
  def self.method_missing(method_name, *arguments, &block)
    if method_name.to_s =~ /^(\w+)=$/
      self[$1] = arguments.first
    else
      self[method_name]
    end
  end

  # No declarar respond_to? true para cualquier método: gemas que hacen sondeo
  # (annotaterb pregunta respond_to?(:translation_class) y luego llama al método,
  # que devuelve nil → rompía db:migrate) y la introspección de validaciones de
  # ActiveRecord se confunden. La notación por punto (AppSetting.lunch_hours)
  # sigue funcionando vía method_missing, que no consulta respond_to?.
  def self.respond_to_missing?(method_name, include_private = false)
    super
  end

  # Automatically convert values to appropriate types
  def self.auto_convert_value(key, value)
    return value if value.nil?

    # List of keys that should be treated as numeric
    numeric_keys = %w[hourly_rate overtime_rate margin_of_tolerance lunch_hours]

    if numeric_keys.include?(key.to_s)
      # Try to convert to integer first
      int_val = value.to_i
      float_val = value.to_f

      # If it looks like a float (has decimal part)
      if float_val != int_val
        return float_val
      else
        return int_val
      end
    end

    # Return original value for non-numeric keys
    value
  end

  # Opcional: métodos con tipos convertidos
  def self.fetch_int(key, default = 0)
    self[key].to_i.presence || default
  end

  def self.fetch_bool(key, default = false)
    ActiveModel::Type::Boolean.new.cast(self[key]) || default
  end
end
