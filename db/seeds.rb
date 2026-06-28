admin_role = Role.find_or_create_by!(name: 'Admin')

# Idempotent: avoids creating duplicate admin/device records if seeds run again
# (e.g. db:prepare on a fresh desktop install). Real client installs ship a
# migrated production.sqlite3 and do not run seeds.
User.find_or_create_by!(email: 'admin@multicarnes.com') do |user|
  user.roles = [ admin_role ]
  user.phone = '+595995352192'
  user.name = 'Multicarnes'
  user.password = '123456'
  user.active = true
end

# Example company roles/groups
company_groups = [
  "Ventas",
  "Marketing",
  "Recursos Humanos",
  "Finanzas",
  "Operaciones",
  "Soporte TI",
  "Atención al Cliente",
  "Desarrollo de Productos",
  "Control de Calidad",
  "Logística",
  "Sereno"
]

company_groups.each do |group_name|
  Group.find_or_create_by!(name: group_name)
end

Device.find_or_create_by!(name: 'Device 1') do |device|
  device.ip_address = '123.123.23.3'
  device.model = '1'
end
