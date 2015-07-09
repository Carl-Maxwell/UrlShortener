desc "Prune urls visited over 5 minutes ago"
task prune: :environment do
  puts ShortenedUrl.all.count
  ShortenedUrl.prune(5)
  puts ShortenedUrl.all.count
end
