100.times do |n|
  User.create!(
    name: Faker::Name.name,
    email: "example#{n<1 ? '' : "-#{n}"}@railstutorial.org",
    password: "password",
    password_confirmation: "password"
  )
end
