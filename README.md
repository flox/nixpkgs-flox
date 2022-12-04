# Nixpkgs-flox

by flox

------

This repository provides a catalog of successful Nixpkgs builds over time
along with flake-based accessors for reliable, versioned access to Nixpkgs.
It is designed for use with [flox](https://floxdev.com), the Multi-Platform
and Reproducible Environment Manager.

## Catalog

The catalog provides snapshots of successful nixpkgs evaluations over time
for all major systems. Catalog metadata is separated by system type and
is served from individual branches containing unrelated commit trees.

- [x86_64-darwin-new](https://github.com/flox/nixpkgs-flox/tree/x86_64-darwin-new)
- [x86_64-darwin](https://github.com/flox/nixpkgs-flox/tree/x86_64-darwin)
- [x86_64-linux-new](https://github.com/flox/nixpkgs-flox/tree/x86_64-linux-new)
- [x86_64-linux](https://github.com/flox/nixpkgs-flox/tree/x86_64-linux)
- [aarch64-darwin-new](https://github.com/flox/nixpkgs-flox/tree/aarch64-darwin-new)
- [aarch64-darwin](https://github.com/flox/nixpkgs-flox/tree/aarch64-darwin)
- [aarch64-linux-new](https://github.com/flox/nixpkgs-flox/tree/aarch64-linux-new)
- [aarch64-linux](https://github.com/flox/nixpkgs-flox/tree/aarch64-linux)

The `*-new` branches contain the same catalog data as on their non-`new`
counterparts, arranged in a hierarchical structure rather than combined in a
single json file. These new branches will replace their non-`new` counterparts
following the successful merge of https://github.com/NixOS/nix/pull/6530.

## Contact us

If there are any other systems you would like to see supported
please [contact us](https://floxdev.com/contact) to let us know
how you'd like to use flox!
