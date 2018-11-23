@sample_users = []
Dir[File.join(Rails.root, 'db', 'seed_material', '*.rb')].sort.each do |seed|
  load seed
end



user = User.create!(
    name: "Antoine",
    email: "antoinerev+antoine@gmail.com",
    password: "123456",
    password_confirmation: "123456"
  )
domain = Domain.find_or_create_by!(name: "Photography")
KnowledgeItem.find_or_create_by!(title: "The best camera is the one you have with you", link: "https://www.amazon.fr/Best-Camera-One-Thats-You/dp/0321684788", domain_id: domain.id, user_id: user.id, kind: 1)
KnowledgeItem.find_or_create_by!(title: "Todo", link: "https://todo/todo.fr", domain_id: domain.id, user_id: user.id, kind: 1)

# map = File.read("db/seed_material/Nicola_links.markdown")
# parsed_map = JSON.parse(map)
@sample_users.each do |sample_user|
  user = User.create!(
      name: sample_user[:user_name],
      email: sample_user[:email],
      password: sample_user[:password],
      password_confirmation: sample_user[:password_confirmation]
    )
  domains = sample_user[:domains]
  domains.each do |domain|
    # puts domain
    new_domain = Domain.find_or_create_by!(name: domain[:domain_name].capitalize)
    if domain[:knowledge_item][:title]
      KnowledgeItem.find_or_create_by!(title: domain[:knowledge_item][:title].capitalize, link: domain[:knowledge_item][:link], kind: domain[:knowledge_item][:kind].to_i, domain_id: new_domain.id, user_id: user.id)
    end
  end
end

