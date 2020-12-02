# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :twitter_clone_elixir,
  ecto_repos: [TwitterCloneElixir.Repo]

# Configures the endpoint
config :twitter_clone_elixir, TwitterCloneElixirWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "h02WEb3nzGQT/xe+q9sByYpHhorbA+CVCNKE55GqbrLRLfHKrs6lUPX0nAhSWz9a",
  render_errors: [view: TwitterCloneElixirWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TwitterCloneElixir.PubSub,
  live_view: [signing_salt: "YEp1vLhb"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ex_aws,
  json_codec: Jason,
  debug_requests: true,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, {:awscli, "default", 30}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, {:awscli, "default", 30}, :instance_role],
  #security_token: [{:system, "AWS_SESSION_TOKEN"}, {:awscli, "default", 30}, :instance_role],
  region: "us-east-1"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
