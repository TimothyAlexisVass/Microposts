(1..99).each do |n|
  u = User.create!(
    name: "Test User #{n}",
    email: "testuser#{n}@example.com",
    password: "password",
    password_confirmation: "password",
    admin: n==1,
    activated: true,
    activated_at: Time.zone.now
  )
end

users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end