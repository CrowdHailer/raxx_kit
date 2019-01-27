use Mix.Config

if Mix.env() == :dev do
  config :exsync,
    extra_extensions: [".js", ".css"]
end
