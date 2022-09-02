{
  # nixpkgs collection
  inputs = {
    nixpkgs.follows = "nixpkgs-stable";
    nixpkgs-stable.url = "github:flox/nixpkgs/stable";
    nixpkgs-unstable.url = "github:flox/nixpkgs/unstable";
    nixpkgs-staging.url = "github:flox/nixpkgs/staging";
  };

  # Catalogs
  inputs = {
    "nixpkgs__catalog__aarch64-darwin" = {
      url = "github:flox/nixpkgs-catalog/aarch64-darwin";
      flake = false;
    };

    "nixpkgs__catalog__x86_64-linux" = {
      url = "github:flox/nixpkgs-catalog/x86_64-linux";
      flake = false;
    };
  };

  # Capacitor inputs
  inputs = {
    capacitor = {
      url = "github:flox/capacitor/v0";
      inputs.root.follows = "/";
    };
    flox-extras = {
      url = "github:flox/flox-extras";
      inputs.capacitor.follows = "capacitor";
    };
  };

  outputs = args @ {capacitor, ...}:
    capacitor args ({
      self,
      inputs,
      systems,
      lib,
      ...
    }: {
      config = {
        systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
        plugins =
          []
          ++ (map (
            value:
              inputs.flox-extras.plugins.catalog {
                catalogDirectory = inputs."nixpkgs__catalog__${value.system}" + "/${value.stability}";
                path = [];
                system = "${value.system}";
              }
              ) [
                {system="x86_64-linux";stability="stable";}
                {system="x86_64-linux";stability="staging";}
                {system="x86_64-linux";stability="unstable";}
                {system="aarch64-darwin";stability="stable";}
                {system="aarch64-darwin";stability="staging";}
                {system="aarch64-darwin";stability="unstable";}
              ])

          # ++ (builtins.concatMap (
          #   system: (map (
          #     stability:
          #       inputs.flox-extras.plugins.catalog {
          #         catalogFile = self.__pins.snapshots."nixpkgs-${stability}".${system};
          #         path = ["snapshots" stability];
          #         system = "${system}";
          #       }
          #     # TODO add staging and unstable after they're getting built by machine
          #   ) ["stable"])
          #   ) ["x86_64-linux" "aarch64-darwin"])
            ;

      };

      passthru = {
        lib = inputs.nixpkgs-stable.lib;
        legacyPackages = lib.genAttrs systems (system: let
          stabilities = lib.genAttrs ["stable" "staging" "unstable"] (
            stability:
              (import inputs."nixpkgs-${stability}" {
                config.allowUnfree = true;
                inherit system;
              })
              // {recurseForDerivations = true;}
          );
        in
          stabilities.stable
          // stabilities
          // {recurseForDerivations = true;});
        stable.legacyPackages = builtins.mapAttrs (_: v: v.stable) self.legacyPackages;
        unstable.legacyPackages = builtins.mapAttrs (_: v: v.unstable) self.legacyPackages;
        staging.legacyPackages = builtins.mapAttrs (_: v: v.staging) self.legacyPackages;

        # AUTO-MANAGED AFTER THIS POINT ##################################
        # AUTO-MANAGED AFTER THIS POINT ##################################
        # AUTO-MANAGED AFTER THIS POINT ##################################
        __pins.snapshots = {
          nixpkgs-stable.aarch64-darwin = builtins.fetchTarball {
            url = https://catalog.floxsdlc.com/nixpkgs/aarch64-darwin.ce49cb7792a7ffd65ef352dda1110a4e4a204eac.tar.gz;
            sha256 = "0qa162w88xrk4g3q0f6xnf5kj6krvp69i4slq5zamabsdcjqipgb";
          };
          nixpkgs-stable.x86_64-linux = builtins.fetchTarball {
            url = https://catalog.floxsdlc.com/nixpkgs/x86_64-linux.ce49cb7792a7ffd65ef352dda1110a4e4a204eac.tar.gz;
            sha256 = "0l2885723584d42md6wafnyxf8dlwbc0zdf58c1mh9zi4hfqiyk5";
          };
          nixpkgs-unstable.aarch64-darwin = builtins.fetchTarball {
            url = https://catalog.floxsdlc.com/nixpkgs/aarch64-darwin.5e804cd8a27f835a402b22e086e36e797716ef8b.tar.gz;
            sha256 = "0gyrrnlnxvl96l2z4aciiv45ihahwbk2b0nm615xjj77bikrb1mf";
          };
          nixpkgs-unstable.x86_64-linux = builtins.fetchTarball {
            url = https://catalog.floxsdlc.com/nixpkgs/x86_64-linux.5e804cd8a27f835a402b22e086e36e797716ef8b.tar.gz;
            sha256 = "19rcdk953lq9g32ym9p73xabikl8pjwybbwyy3d9xqdw0midd7n6";
          };
          nixpkgs-staging.aarch64-darwin = builtins.fetchTarball {
            url = https://catalog.floxsdlc.com/nixpkgs/aarch64-darwin.12363fb6d89859a37cd7e27f85288599f13e49d9.tar.gz;
            sha256 = "0bmdnzxg2q087qxiqz6siy3i8288s970blrnpqj7zzgzylifx5ns";
          };
          nixpkgs-staging.x86_64-linux = builtins.fetchTarball {
            url = https://catalog.floxsdlc.com/nixpkgs/x86_64-linux.12363fb6d89859a37cd7e27f85288599f13e49d9.tar.gz;
            sha256 = "0vmdjqwiik1l0yrvy91f95vsj38mw8blcd1b7jzihb2w7rmck2zz";
          };
        };
      };
    });
}
