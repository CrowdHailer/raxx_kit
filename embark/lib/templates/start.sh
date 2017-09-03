# NOTE dependencies should be fetched before this step,
# so they are committed to mix.lock.
mix deps.get

# NOTE this is because of errors in reompiling `.eex` and `.apib` files
mix compile

elixir --name web@$(hostname -I) --cookie secret -S mix run --no-halt
