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
# app/models/setting.rb
class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # Métodos de clase
  def self.[](key)
    find_by(key: key.to_s)&.value
  end

  def self.[]=(key, value)
    record = find_or_initialize_by(key: key.to_s)
    record.value = value
    record.save!
  end

  # Support for dot notation access (Setting.lunch_hours)
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

  # Opcional: métodos con tipos convertidos
  def self.fetch_int(key, default = 0)
    self[key].to_i.presence || default
  end

  def self.fetch_bool(key, default = false)
    ActiveModel::Type::Boolean.new.cast(self[key]) || default
  end
end

