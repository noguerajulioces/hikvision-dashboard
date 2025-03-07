# RailsSettings Model
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
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  # Define your fields
  field :margin_of_tolerance, type: :string, default: "5"
  field :hourly_rate, type: :integer, default: 10_000
  field :overtime_rate, type: :integer, default: 15_000
  field :lunch_hours, type: :integer, default: 1

  # New fields
  field :hr_manager_name, type: :string, default: "Guillermo Godoy" # Encargado Personal
  field :hr_manager_title, type: :string, default: "Encargado Personal"

  field :admin_manager_name, type: :string, default: "Anabella Oviedo" # Encargado Administrativo
  field :admin_manager_title, type: :string, default: "Encargado Administrativo"
  # field :default_locale, default: "en", type: :string
  # field :confirmable_enable, default: "0", type: :boolean
  # field :admin_emails, default: "admin@rubyonrails.org", type: :array
  # field :omniauth_google_client_id, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_ID"] || ""), type: :string, readonly: true
  # field :omniauth_google_client_secret, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"] || ""), type: :string, readonly: true
end
