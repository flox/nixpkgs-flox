# Wrapper of Nixpkgs

Uses github:flox/nixpkgs to

Generate a cache of historical data for a package in $HOME/.cache/flox/versions:
```
nix run github:flox/nixpkgs-flox#versionsOf n2n | jq
```

Look in $HOME/.cache/flox/versions/**NAME**/manifest.json for historical data:
```
nix eval github:flox/nixpkgs-flox#cachedPackages.x86_64-linux.n2n  --impure --json | jq
```

TODO: load multiple manifest.json into a DB and generate dynamic manifests for more detailed or complicated queries
