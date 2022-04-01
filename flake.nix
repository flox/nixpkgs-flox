{
  inputs.nixpkgs.url = "github:flox/nixpkgs/staging";
  inputs.capacitor.url = "git+ssh://git@github.com/flox/capacitor";

  outputs = self: {
    apps = self.capacitor.lib.makeApps self.nixpkgs;
  };
}
