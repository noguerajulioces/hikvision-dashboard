admin_role = Role.find_or_create_by!(name: 'Admin')

user = User.create(roles: [ admin_role ], phone: '+595995352192', email: 'admin@multicarnes.com', name: 'Multicarnes', password: 123456, active: true)

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

Device.create(name: 'Device 1', ip_address: '123.123.23.3', model: '1')
