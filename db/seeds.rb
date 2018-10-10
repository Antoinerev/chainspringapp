# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user = User.create(name: "Antoine")
domain = Domain.create(name: "photography")
KnowledgeItem.create(title: "the best camera is the one you have with you", link: "https://www.amazon.fr/Best-Camera-One-Thats-You/dp/0321684788", domain: domain, user: user, kind: 1)
