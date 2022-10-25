# nixpkgs catalog

by flox

------

Catalog of nixpkgs for all major systems.

Catalogs are separated by system and live on individual branches.

- [x86_64-darwin-new](https://github.com/flox/nixpkgs-catalog/tree/x86_64-darwin-new)
- [x86_64-darwin](https://github.com/flox/nixpkgs-catalog/tree/x86_64-darwin)
- [x86_64-linux-new](https://github.com/flox/nixpkgs-catalog/tree/x86_64-linux-new)
- [x86_64-linux](https://github.com/flox/nixpkgs-catalog/tree/x86_64-linux)
- [aarch64-darwin-new](https://github.com/flox/nixpkgs-catalog/tree/aarch64-darwin-new)
- [aarch64-darwin](https://github.com/flox/nixpkgs-catalog/tree/aarch64-darwin)
- [aarch64-linux-new](https://github.com/flox/nixpkgs-catalog/tree/aarch64-linux-new)
- [aarch64-linux](https://github.com/flox/nixpkgs-catalog/tree/aarch64-linux)

The `*-new` branches contain the same catalogs as their non `new` counterpart,
but spread accross a file tree rather than combined into a single file.

Updates to the catalog are propagated to `nixpkgs-flox` by a github action in `.github/workflows/trigger-update.yml`.

Changes to this file have to be merged into **all** catalog branches to take effect for all.

Note that the non-new branches are an unrelated commit tree, main needs to be merged using

```
git merge main --allow-unrelated-histories
```

Merge all all branches using this script:

``` bash
for branch in x86_64-darwin-new x86_64-darwin x86_64-linux-new x86_64-linux aarch64-darwin-new aarch64-darwin aarch64-linux-new aarch64-linux; do
  git switch "$branch"
  git merge main --allow-unrelated-histories
done
```
