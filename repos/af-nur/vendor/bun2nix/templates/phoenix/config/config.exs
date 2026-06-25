# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bun2nix_phoenix,
  ecto_repos: [Bun2nixPhoenix.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :bun2nix_phoenix, Bun2nixPhoenixWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: Bun2nixPhoenixWeb.ErrorHTML, json: Bun2nixPhoenixWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Bun2nixPhoenix.PubSub,
  live_view: [signing_salt: "u9LNdMxX"]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :bun2nix_phoenix, Bun2nixPhoenix.Mailer, adapter: Swoosh.Adapters.Local

# Configure bun (the version is required)
config :bun,
  version: "1.3.1",
  assets: [
    args: [],
    cd: Path.expand("../assets", __DIR__)
  ],
  js: [
    args:
      ~w(build js/app.ts --outdir=../priv/static/assets --external /fonts/* --external /images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{
      "NODE_PATH" => Mix.Project.build_path()
    }
  ],
  css: [
    args: ~w(run tailwindcss --output=../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
