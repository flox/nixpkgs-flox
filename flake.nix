rec {
  inputs.nixpkgs.url = "github:flox/nixpkgs/stable";
  inputs.nixpkgs.follows = "nixpkgs-stable";

  inputs.nixpkgs-stable.url = "github:flox/nixpkgs/stable";
  inputs.nixpkgs-unstable.url = "github:flox/nixpkgs/unstable";
  inputs.nixpkgs-staging.url = "github:flox/nixpkgs/staging";

  inputs.nix-eval-jobs.url = "github:tomberek/nix-eval-jobs";
  inputs.nix-editor.url = "github:vlinkz/nix-editor";
  inputs.nix-editor.inputs.nixpkgs.follows = "nixpkgs";

  outputs = args @ {
    self,
    nixpkgs,
    nix-eval-jobs,
    nix-editor,
    ...
  }: {
    __systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    legacyPackages = nixpkgs.lib.genAttrs self.__systems (system: let
      pkgs = nixpkgs.lib.genAttrs ["stable" "staging" "unstable"] (
        stability:
          (import args."nixpkgs-${stability}" {
            config.allowUnfree = true;
            inherit system;
          })
          // {
            recurseForDerivations = true;
            nix-editor = args.nix-editor.packages.${system}.nixeditor;
          }
      );
    in
      pkgs
      // pkgs.stable
      // {recurseForDerivations = true;});

    stable.legacyPackages = builtins.mapAttrs (_: v: v.stable) self.legacyPackages;
    unstable.legacyPackages = builtins.mapAttrs (_: v: v.unstable) self.legacyPackages;
    staging.legacyPackages = builtins.mapAttrs (_: v: v.staging) self.legacyPackages;
    packages = builtins.mapAttrs (system: pkgs:
      with pkgs; {
        full-eval =
          runCommand "full-eval.tar.gz" {
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
              --flake ${nixpkgs}#legacyPackages.${system} \
              --depth 1 \
              | jq -c '.originalUri = "${inputs.nixpkgs.url}" |
                       .uri = "${builtins.dirOf inputs.nixpkgs.url}/${nixpkgs.rev}"' \
              | tee /dev/fd/2 | \
                jq -sf ${./split.jq} > self/pkgs.json
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
      }) nixpkgs.legacyPackages;

    lib = args.nixpkgs-stable.lib;
    stabilities = {inherit (self) stable unstable staging;};
  };
}
