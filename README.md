# Wrapper of Nixpkgs

Uses github:flox/nixpkgs to

Generate a cache of historical data for a package in $HOME/.cache/flox/versions:
```
nix run github:flox/nixpkgs-flox#versionsOf n2n | jq
```

Look in $HOME/.cache/flox/versions/**NAME**/manifest.json for historical data:
```
$ nix eval github:flox/nixpkgs-flox#cachedPackages.x86_64-linux.n2n  --impure --json | jq
{
  "stable": "/nix/store/i9j3z7psg1xyp817vqkxla8mp8kiqi7b-n2n-3.0",
  "stable_20220205": "/nix/store/5qw5gggbvjhc41l2vjdr0vvsi9i9dh2g-n2n-2.8",
  "staging": "/nix/store/3pj1w7ms7lzqajrqxhd524b1kmk1lj45-n2n-3.0",
  "staging_20210904": "/nix/store/5qw5gggbvjhc41l2vjdr0vvsi9i9dh2g-n2n-2.8",
  "staging_20220122": "/nix/store/idx3czj5a04hrprgrfipwajvw0h7gnnw-n2n-2.8",
  "staging_20220402": "/nix/store/i9j3z7psg1xyp817vqkxla8mp8kiqi7b-n2n-3.0",
  "unstable": "/nix/store/zxv0q307xsc47fbq2s5v4zyi3sscl2ig-n2n-3.0",
  "unstable_20210901": "/nix/store/5qw5gggbvjhc41l2vjdr0vvsi9i9dh2g-n2n-2.8",
  "unstable_20220105": "/nix/store/idx3czj5a04hrprgrfipwajvw0h7gnnw-n2n-2.8",
  "unstable_20220113": "/nix/store/idx3czj5a04hrprgrfipwajvw0h7gnnw-n2n-2.8",
  "unstable_20220323": "/nix/store/i9j3z7psg1xyp817vqkxla8mp8kiqi7b-n2n-3.0",
  "unstable_20220413": "/nix/store/3pj1w7ms7lzqajrqxhd524b1kmk1lj45-n2n-3.0"
}
```

TODO: load multiple manifest.json into a DB and generate dynamic manifests for more detailed or complicated queries
