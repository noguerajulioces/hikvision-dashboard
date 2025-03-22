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

  # Opcional: métodos con tipos convertidos
  def self.fetch_int(key, default = 0)
    self[key].to_i.presence || default
  end

  def self.fetch_bool(key, default = false)
    ActiveModel::Type::Boolean.new.cast(self[key]) || default
  end
end

