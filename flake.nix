rec {
  inputs.nixpkgs.url = "github:flox/nixpkgs/unstable";
  inputs.capacitor.url = "git+ssh://git@github.com/flox/capacitor?ref=ysndr";
  inputs.capacitor.inputs.root.follows = "/";

  inputs.nix-eval-jobs.url = "github:tomberek/nix-eval-jobs";

  outputs = args@{self, nixpkgs, capacitor,nix-eval-jobs}:
  capacitor args (_: {
    legacyPackages = {system,...}: import nixpkgs {
      config.allowUnfree = true;
      inherit system;
    };

    packages.full-eval = {system,...}: let
          system = "x86_64-linux";
    in with nixpkgs.legacyPackages.${system};
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
  });
}
