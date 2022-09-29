(1..99).each do |n|
  User.create!(
    name: "Test User #{n}",
    email: "testuser#{n}@example.com",
    password: "password",
    password_confirmation: "password",
    admin: n==1
  )
end
