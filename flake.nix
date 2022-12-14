{
  # nixpkgs collection
  inputs = {
    nixpkgs.url = "github:flox/nixpkgs/stable";
    nixpkgs-stable.url = "github:flox/nixpkgs/stable";
    nixpkgs-unstable.url = "github:flox/nixpkgs/unstable";
    nixpkgs-staging.url = "github:flox/nixpkgs/staging";
  };

  # Catalogs
  inputs = {
    "nixpkgs__catalog__aarch64-darwin" = {
      url = "github:flox/nixpkgs-catalog/aarch64-darwin?host=catalog.floxsdlc.com";
      flake = false;
    };

    "nixpkgs__catalog__aarch64-linux" = {
      url = "github:flox/nixpkgs-catalog/aarch64-linux?host=catalog.floxsdlc.com";
      flake = false;
    };

    "nixpkgs__catalog__x86_64-linux" = {
      url = "github:flox/nixpkgs-catalog/x86_64-linux?host=catalog.floxsdlc.com";
      flake = false;
    };

    "nixpkgs__catalog__x86_64-darwin" = {
      url = "github:flox/nixpkgs-catalog/x86_64-darwin?host=catalog.floxsdlc.com";
      flake = false;
    };
  };

  # Capacitor inputs
  inputs = {
    floxpkgs = {
      url = "github:flox/floxpkgs";
    };
  };
  inputs.floxpkgs.inputs.nixpkgs.follows = "/";

  outputs = args @ {floxpkgs, ...}:
    floxpkgs.project args ({
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
              catalog:
                inputs.floxpkgs.plugins.catalog {
                  catalogDirectory = catalog;
                  path = [];
                }
            )
            (inputs.nixpkgs.lib.attrValues
              (inputs.nixpkgs.lib.filterAttrs (name: _: inputs.nixpkgs.lib.hasPrefix "nixpkgs__catalog__" name) inputs)));
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
          # treat nixpkgs input as default nipkgs (following stable, by default)
          (import inputs.nixpkgs {
                config.allowUnfree = true;
                inherit system;
          })
          // stabilities
          // {recurseForDerivations = true;});
        stable.legacyPackages = builtins.mapAttrs (_: v: v.stable) self.legacyPackages;
        unstable.legacyPackages = builtins.mapAttrs (_: v: v.unstable) self.legacyPackages;
        staging.legacyPackages = builtins.mapAttrs (_: v: v.staging) self.legacyPackages;

        __functor = _: import inputs.nixpkgs;

      };
    });
}
