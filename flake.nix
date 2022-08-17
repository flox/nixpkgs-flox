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
    "nixpkgs.catalog.aarch64-darwin" = {
      url = "https://catalog.floxsdlc.com/nixpkgs/catalog.aarch64-darwin.tar.gz";
      flake = false;
    };

    "nixpkgs.catalog.x86_64-linux" = {
      url = "https://catalog.floxsdlc.com/nixpkgs/catalog.x86_64-linux.tar.gz";
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
            system:
              inputs.flox-extras.plugins.catalog {
                catalogFile = inputs."nixpkgs.catalog.${system}";
                system = "${system}";
              }
          ) ["x86_64-linux" "aarch64-darwin"])
          ++ (builtins.concatMap (
            system: (map (
              stability:
                inputs.flox-extras.plugins.catalog {
                  catalogFile = self.__pins.snapshots."nixpkgs-${stability}".${system};
                  path = ["snapshots" stability];
                  system = "${system}";
                }
              # TODO add staging and unstable after they're getting built by machine
            ) ["stable"])
          ) ["x86_64-linux" "aarch64-darwin"]);
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
            sha256 = "1hasjnk2b847hd11rpmxlsczc0bv8miwz9bbncbsvwhvmpr42jcg";
          };
          nixpkgs-stable.x86_64-linux = builtins.fetchTarball {
            url = https://catalog.floxsdlc.com/nixpkgs/x86_64-linux.ce49cb7792a7ffd65ef352dda1110a4e4a204eac.tar.gz;
            sha256 = "0zvzqs46nv6mp631d70nvbsf7hsx2b5awpiyb61mwjg0wjbqkw6c";
          };
        };
      };
    });
}
