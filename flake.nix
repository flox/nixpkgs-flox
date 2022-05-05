rec {
  inputs.staging.url = "github:flox/nixpkgs/staging";
  inputs.stable.url = "github:flox/nixpkgs/stable";
  inputs.unstable.url = "github:flox/nixpkgs/unstable";

  inputs.capacitor.url = "git+ssh://git@github.com/flox/capacitor";
  inputs.nix-eval-jobs.url = "github:tomberek/nix-eval-jobs";

  inputs.tagList.url = "path:./tag.list.json";
  inputs.tagList.flake = false;
  inputs.attrList.url = "path:./attr.list.json";
  inputs.attrList.flake = false;

  outputs = args@{
    self,
    capacitor,
    nix-eval-jobs,
    ...
  }: let
    nixpkgs = args.stable;
    combined = nixpkgs.lib.recursiveUpdate {legacyPackages=nixpkgs.legacyPackages;} capacitor-apps;
    capacitor-apps = args.capacitor.lib.makeApps;
  in
    nixpkgs.lib.recursiveUpdate combined
    {
      full-eval = let
        system = "x86_64-linux";
      in
        with nixpkgs.legacyPackages.x86_64-linux;
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
            mkdir temp gc self $out
            nix-eval-jobs --gc-roots-dir $PWD/gc \
              --flake ${nixpkgs}#legacyPackages.${system}.python3Packages \
              --depth 2 \
              | jq -c '.originalUri = "${inputs.nixpkgs.url}" |
                       .uri = "${inputs.nixpkgs.url}/${nixpkgs.rev}"' \
              | tee /dev/fd/2 | jq -cs '{elements:.,version:1}' > $out/manifest.json
          '';
    };
}
