rec {
  inputs.nixpkgs.url = "github:flox/nixpkgs/unstable";
  inputs.capacitor.url = "git+ssh://git@github.com/flox/capacitor";
  inputs.capacitor.inputs.root.follows = "/";

  inputs.nixpkgs-stable.url = "github:flox/nixpkgs/stable";
  inputs.nixpkgs-unstable.url = "github:flox/nixpkgs/unstable";
  inputs.nixpkgs-staging.url = "github:flox/nixpkgs/staging";

  inputs.nix-eval-jobs.url = "github:tomberek/nix-eval-jobs";

  outputs = args @ {
    self,
    nixpkgs,
    capacitor,
    nix-eval-jobs,
    ...
  }:
    (capacitor args (_: {
      legacyPackages = {system, ...}: let
        pkgs = nixpkgs.lib.genAttrs ["stable" "staging" "unstable"] (
          stability:
            (import args."nixpkgs-${stability}" {
              config.allowUnfree = true;
              inherit system;
            })
            // {recurseForDerivations = true;}
        );
      in pkgs
        // pkgs.unstable
        // {recurseForDerivations = true;};

      packages.full-eval = {system, ...}: let
        system = "x86_64-linux";
      in
        with nixpkgs.legacyPackages.${system};
          runCommand "full-eval" {
            nativeBuildInputs = [
              nixUnstable
              jq
              nix-eval-jobs.defaultPackage.${system}
            ];
            allowedReferences = [];
          } ''
            export HOME=$PWD
            export GC_DONT_GC=1
            export NIX_CONFIG="experimental-features = flakes nix-command
            store = $PWD/temp
            "
            mkdir temp gc self
            nix-eval-jobs --gc-roots-dir $PWD/gc \
              --flake ${nixpkgs}#legacyPackages.${system}.perlPackages \
              --depth 1 \
              | jq -c '.originalUri = "${inputs.nixpkgs.url}" |
                       .uri = "${builtins.dirOf inputs.nixpkgs.url}/${nixpkgs.rev}"' \
              | tee /dev/fd/2 | \
                jq -sf ${capacitor}/lib/split.jq > self/pkgs.json
            cp ${./template.nix} self/flake.nix
            cat > self/flake.lock <<EOF
            {
              "nodes": {
                "root": {}
              },
              "root": "root",
              "version": 7
            }
            EOF
            tar -acf $out self
          '';
        })) //
        {lib = args.nixpkgs-unstable.lib;}
        ;
}
