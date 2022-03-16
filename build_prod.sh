MIX_ENV=prod mix phx.digest.clean --all
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release --overwrite
