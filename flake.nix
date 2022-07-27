rec {
  inputs.nixpkgs.follows = "nixpkgs-stable";

  inputs.nixpkgs-stable.url = "github:flox/nixpkgs/stable";
  inputs.nixpkgs-unstable.url = "github:flox/nixpkgs/unstable";
  inputs.nixpkgs-staging.url = "github:flox/nixpkgs/staging";

  inputs.capacitor.url = "github:flox/capacitor/v0";
  inputs.capacitor.inputs.root.follows = "/";

  inputs.nix-eval-jobs.url = "github:tomberek/nix-eval-jobs";
  inputs.nix-editor.url = "github:vlinkz/nix-editor";
  inputs.nix-editor.inputs.nixpkgs.follows = "nixpkgs";

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
        plugins = [];
      };

      passthru = {
        lib = inputs.nixpkgs-unstable.lib;
        legacyPackages = lib.genAttrs systems (system: let
          pkgs = lib.genAttrs ["stable" "staging" "unstable"] (
            stability:
              (import inputs."nixpkgs-${stability}" {
                config.allowUnfree = true;
                inherit system;
              })
              // {recurseForDerivations = true;}
          );
        in
          pkgs
          // {recurseForDerivations = true;});
        stable.legacyPackages = builtins.mapAttrs (_: v: v.stable) self.legacyPackages;
        unstable.legacyPackages = builtins.mapAttrs (_: v: v.unstable) self.legacyPackages;
        staging.legacyPackages = builtins.mapAttrs (_: v: v.staging) self.legacyPackages;
      };
    });
}
