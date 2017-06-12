# NOTE dependencies should be fetched before this step,
# so they are committed to mix.lock.
mix deps.get

elixir --name web@$(hostname -I) --cookie secret -S mix run --no-halt
