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

# Example employees data
employees = [
  {
    first_name: "Juan",
    last_name: "Pérez",
    email: "juan.perez@example.com",
    phone: "+595991234567",
    document_number: "1234567",
    hire_date: Date.today,
    group_id: 1
  },
  {
    first_name: "María",
    last_name: "García",
    email: "maria.garcia@example.com",
    phone: "+595992345678",
    document_number: "2345678",
    hire_date: Date.today,
    group_id: 2
  },
  {
    first_name: "Carlos",
    last_name: "López",
    email: "carlos.lopez@example.com",
    phone: "+595993456789",
    document_number: "3456789",
    hire_date: Date.today,
    group_id: 3
  },
  {
    first_name: "Ana",
    last_name: "Martínez",
    email: "ana.martinez@example.com",
    phone: "+595994567890",
    document_number: "4567890",
    hire_date: Date.today,
    group_id: 4
  },
  {
    first_name: "Roberto",
    last_name: "Sánchez",
    email: "roberto.sanchez@example.com",
    phone: "+595995678901",
    document_number: "5678901",
    hire_date: Date.today - 23.days,
    group_id: 5
  },
  {
    first_name: "Laura",
    last_name: "Torres",
    email: "laura.torres@example.com",
    phone: "+595996789012",
    document_number: "6789012",
    hire_date: Date.today - 10.days,
    group_id: 6
  },
  {
    first_name: "Miguel",
    last_name: "Rodríguez",
    email: "miguel.rodriguez@example.com",
    phone: "+595997890123",
    document_number: "7890123",
    hire_date: Date.today - 50.days,
    group_id: 7
  },
  {
    first_name: "Sofia",
    last_name: "Ramírez",
    email: "sofia.ramirez@example.com",
    phone: "+595998901234",
    document_number: "8901234",
    hire_date: Date.today - 5.days,
    group_id: 8
  },
  {
    first_name: "Diego",
    last_name: "González",
    email: "diego.gonzalez@example.com",
    phone: "+595999012345",
    document_number: "9012345",
    hire_date: Date.today - 40.days,
    group_id: 9
  },
  {
    first_name: "Carmen",
    last_name: "Silva",
    email: "carmen.silva@example.com",
    phone: "+595990123456",
    document_number: "0123456",
    hire_date: Date.today - 30.days,
    group_id: 10
  }
]

# Create employees
employees.each do |employee_data|
  Employee.find_or_create_by!(
    first_name: employee_data[:first_name],
    last_name: employee_data[:last_name],
    email: employee_data[:email],
    phone: employee_data[:phone],
    document_number: employee_data[:document_number],
    hire_date: employee_data[:hire_date],
    group_id: employee_data[:group_id]
  )
end

require 'faker'

employees = []

30.times do
  employees << {
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.cell_phone,
    document_number: Faker::Number.number(digits: 7),
    hire_date: Faker::Date.between(from: 60.days.ago, to: Date.today),
    group_id: rand(1..10) # Asigna un grupo aleatorio entre 1 y 10
  }
end

Employee.create!(employees)

Device.create(name: 'Device 1', ip_address: '123.123.23.3', model: '1')
