# Distributed tests spin up real peer nodes; opt in with `mix test --include distributed`.
ExUnit.configure(exclude: [:distributed])
ExUnit.start()
