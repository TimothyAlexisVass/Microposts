100.times do |n|
  User.create!(
    name: "Example User #{n+1}",
    email: "testuser#{n<1 ? '' : "-#{n}"}@example.com",
    password: "password",
    password_confirmation: "password"
  )
end
