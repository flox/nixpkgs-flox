rec {
  inputs.nixpkgs.url = "github:flox/nixpkgs/staging";
  inputs.capacitor.url = "github:flox/capacitor";
  inputs.nix-eval-jobs.url = "github:tomberek/nix-eval-jobs";

  outputs = {
    self,
    nixpkgs,
    capacitor,
    nix-eval-jobs,
  }: let
    capacitor-apps = capacitor.lib.makeApps combined nixpkgs;
    combined = nixpkgs.lib.recursiveUpdate nixpkgs capacitor-apps;
  in
    nixpkgs.lib.recursiveUpdate combined
    {

      # Use this to fetch the data.
      # nix eval --impure --json path:.#cachedPackages.x86_64-linux.n2n | jq
      # install
      # nix profile install --impure path:.#cachedPackages.x86_64-linux.n2n.stable --max-jobs 0
      cachedPackages =
        nixpkgs.lib.genAttrs ["x86_64-linux"] (system:
        nixpkgs.lib.genAttrs (builtins.attrNames nixpkgs.legacyPackages.${system}) (attr:

         with nixpkgs.lib;
         attrsets.mapAttrsRecursiveCond
         (x: !(x?outPath))
         (path: a:

         let
           theFlake = (builtins.getFlake a.element.uri);
           getFlake = attrsets.attrByPath (["legacyPackages" system attr]) "does not exist" theFlake;
         in
           getFlake

         )
         (builtins.fromJSON (builtins.readFile
         (
         /. + (builtins.getEnv "HOME") + "/.cache/flox/versions/${attr}/manifest.json"
         )
         )).legacyPackages.${system}.${attr}));

      # Use this to generate the data.
      apps.x86_64-linux = {
        ghRepoTags = {
          type = "app";
          program = with nixpkgs.legacyPackages.x86_64-linux; (writeShellApplication {
            name = "ghRepoTags";
            runtimeInputs = [gh];
            text = ''
                gh api --method GET  \
                -H "Accept: application/vnd.github.v3+json" \
                /repos/flox/nixpkgs/git/refs/tags | jq -r .[].ref | cut -d '/' -f 3
                '';
          }) + "/bin/ghRepoTags";
        };
        versionsOf = {
          type = "app";
          program = with nixpkgs.legacyPackages.x86_64-linux; (writeShellApplication {
            name = "versionsOf";
            runtimeInputs = [jq coreutils];
            text = ''
              mkdir -p "$HOME/.cache/flox/versions/$1"

              nix eval ${self}#versionsOf."$1" --json --impure | \
              jq .elements[] -cr | \
              ${capacitor.apps.x86_64-linux.checkCache.program} \
                --db-path "$HOME/.cache/flox/versions/cache.sqlite" \
                --substituter https://cache.nixos.org \
                --substituter https://storehouse.beta.floxdev.com \
                -u grep | \
              jq -sf ${capacitor}/lib/split.jq | \
              tee "$HOME/.cache/flox/versions/$1/manifest.json"
            '';
          }) + "/bin/versionsOf";
        };
      };

      versionsOf = with nixpkgs.lib.attrsets;
        genAttrs (builtins.attrNames nixpkgs.legacyPackages.x86_64-linux) (
          attrpath: let
            # TODO: use this to fetch from on-nix?
            # data = builtins.fromJSON (builtins.readFile (builtins.fetchurl "https://raw.githubusercontent.com/on-nix/pkgs/main/data/nixpkgs/attrs/${attrpath}.json"));
          in {
            version = 2;
            elements =
              builtins.map (
                v: let
                  commit = v;
                  # treeT = builtins.fetchTree "https://github.com/flox/nixpkgs/archive/${commit}.tar.gz";
                  # tryT = import tree {};
                  tree = builtins.getFlake "github:flox/nixpkgs/${commit}";
                  try = tree.legacyPackages.x86_64-linux;
                in {
                  active = true;
                  attrPath = "legacyPackages.x86_64-linux.${attrpath}.${capacitor.lib.sanitizeVersionName v}";
                  originalUri = "github:flox/nixpkgs/${commit}";
                  storePaths = [try.${attrpath}];
                  uri = "github:flox/nixpkgs/${tree.sourceInfo.rev}";
                }
              )
              [
"stable"
"staging"
"unstable"
"stable.20210904"
"stable.20220205"
"staging.20210904"
"staging.20211009"
"staging.20220108"
"staging.20220122"
"staging.20220402"
"unstable.20210901"
"unstable.20210928"
"unstable.20220103"
"unstable.20220105"
"unstable.20220113"
"unstable.20220323"
"unstable.20220413"
              ];
            #data.versions;
            # getFlake
          }
        );

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
