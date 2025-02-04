admin_role = Role.find_or_create_by!(name: 'Admin')

user = User.create(roles: [ admin_role ], phone: '+595995352192', email: 'noguerajulio24@gmail.com', name: 'Julio Noguera', password: 123456)

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
  "Logística"
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


# Lista de horarios de trabajo
shifts = [
  { entry: "06:00", exit: "14:00" }, # Turno Mañana
  { entry: "14:00", exit: "22:00" }, # Turno Tarde
  { entry: "22:00", exit: "06:00" }, # Turno Noche
  { entry: "08:00", exit: "17:00" }  # Horario de Oficina
]

# Precargar todos los grupos en memoria
groups = Group.all.to_a

dates = Date.new(2025, 1, 1)..Date.new(2025, 1, 30)
# Iterar sobre los días del mes
dates.each do |date|
  groups.each do |group|
    shifts.each do |shift|
      puts "DATE: #{date}"
      schedule = Schedule.find_or_initialize_by(date: date, group_id: group.id)

      # Convert shift times to DateTime by combining with the date
      entry_time = "#{date} #{shift[:entry]}".to_datetime
      exit_time = "#{date} #{shift[:exit]}".to_datetime

      # Handle overnight shifts where exit time is on the next day
      exit_time += 1.day if exit_time < entry_time

      # Asignar valores
      schedule.expected_entry_time = entry_time
      schedule.expected_exit_time = exit_time

      # Guardar los cambios si es un nuevo registro o si hay cambios
      schedule.save!
    end
  end
end

Device.create(name: 'Device 1', ip_address: '123.123.23.3', model: '1')


# Attendance Records
employees = Employee.all
schedules = Schedule.all
devices = Device.all

# Generate random attendance records for each employee and their schedules
employees.each do |employee|
  employee_schedules = schedules.where(group_id: employee.group_id)

  employee_schedules.each do |schedule|
    # 80% chance of creating an attendance record
    if rand < 0.8
      # Random variation in entry time (-30 to +15 minutes from expected)
      entry_variation = rand(-30..15).minutes
      entry_time = schedule.expected_entry_time + entry_variation

      # Random variation in exit time (-15 to +30 minutes from expected)
      exit_variation = rand(-15..30).minutes
      exit_time = schedule.expected_exit_time + exit_variation

      # Select a random shift
      random_shift = shifts.sample

      # Generate random dates within a 30-day range
      random_date = Date.today - rand(30).days

      entry_time = "#{random_date} #{random_shift[:entry]}".to_datetime
      exit_time = "#{random_date} #{random_shift[:exit]}".to_datetime

      # Handle overnight shifts where exit time is on the next day
      exit_time += 1.day if exit_time < entry_time

      AttendanceRecord.create!(
        employee: employee,
        schedule: schedule,
        device_id: 1,
        entry_time: entry_time,
        exit_time: exit_time,
        processed: [ true, false ].sample
      )
    end
  end
end
