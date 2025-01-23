## FOR TESTING

5.times do
  Group.create!(
    name: Faker::Company.name
  )
end

20.times do
  Employee.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    group_id: Group.pluck(:id).sample,
    hire_date: Faker::Date.between(from: 5.years.ago, to: Date.today),
    termination_date: [nil, Faker::Date.between(from: Date.today, to: 1.year.from_now)].sample,
    phone: Faker::PhoneNumber.cell_phone_in_e164,
    email: Faker::Internet.email
  )
end

5.times do
  Device.create!(
    name: Faker::Device.model_name,
    ip_address: Faker::Internet.ip_v4_address,
    model: Faker::Alphanumeric.alpha(number: 6)
  )
end

Employee.all.each do |employee|
  10.times do
    entry_time = Faker::Time.between(from: DateTime.now - 30, to: DateTime.now - 1)
    exit_time = entry_time + rand(6..12).hours # Genera un tiempo de salida entre 6 a 12 horas después de la entrada

    AttendanceRecord.create!(
      employee_id: employee.id,
      device_id: Device.pluck(:id).sample,
      entry_time: entry_time,
      exit_time: exit_time,
      processed: [true, false].sample
    )
  end
end


Employee.all.each do |employee|
  2.times do
    Absence.create!(
      employee_id: employee.id,
      start_date: Faker::Date.backward(days: 20),
      end_date: Faker::Date.backward(days: 10),
      absence_type: Absence.absence_types.keys.sample,
      reason: Faker::Lorem.sentence
    )
  end
end

Employee.all.each do |employee|
  3.times do
    Incident.create!(
      employee_id: employee.id,
      date: Faker::Date.backward(days: 30),
      issue: Faker::Lorem.sentence,
      resolved: [true, false].sample
    )
  end
end

Group.all.each do |group|
  (1..6).each do |day|
    Schedule.create!(
      group_id: group.id,
      day_of_week: day,
      expected_entry_time: '09:00',
      expected_exit_time: '17:00'
    )
  end
end

Employee.all.each do |employee|
  5.times do
    OvertimeRecord.create!(
      employee_id: employee.id,
      date: Faker::Date.backward(days: 60),
      hours_worked: rand(1.0..4.0).round(2),
      compensation: rand(50.0..200.0).round(2)
    )
  end
end

10.times do
  User.create!(
    email: Faker::Internet.unique.email,
    password: 'password',
    name: Faker::Name.name,
    phone: Faker::PhoneNumber.cell_phone_in_e164,
    active: [true, false].sample
  )
end

User.create!(
  email: 'noguerajulio24@gmail.com',
  password: '123456',
  name: 'Julio Noguera',
  phone: '1234567890',
  active: true,
  role: Role.find_by(name: 'admin')
)
