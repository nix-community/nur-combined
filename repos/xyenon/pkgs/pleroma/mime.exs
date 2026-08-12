config :mime, :types, %{
  "application/xml" => ["xml"],
  "application/xrd+xml" => ["xrd+xml"],
  "application/jrd+json" => ["jrd+json"],
  "application/activity+json" => ["activity+json"],
  "application/ld+json" => ["activity+json"],
  # Can be removed when bumping MIME past 2.0.5
  # see https://akkoma.dev/AkkomaGang/akkoma/issues/657
  "image/apng" => ["apng"]
}
