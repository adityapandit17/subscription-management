10.times do |i|
  User.find_or_create_by(email: "user#{i}@example.com") do |user|
    user.password = "password#{i}"
  end
end
