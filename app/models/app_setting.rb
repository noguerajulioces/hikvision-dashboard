# == Schema Information
#
# Table name: settings
#
#  id         :bigint           not null, primary key
#  value      :text
#  var        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_settings_on_var  (var) UNIQUE
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

  def self.respond_to_missing?(method_name, include_private = false)
    true
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
