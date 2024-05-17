
Granite::Connections << Granite::Adapter::Sqlite.new(
  name: "main",
  url: Amber.settings.database_url,
)
