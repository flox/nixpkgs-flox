{
  inputs.nixpkgs.url = "github:flox/nixpkgs/staging";
  inputs.capacitor.url = "path:/home/tom/flox/capacitor";

  outputs = self: {
    apps = self.capacitor.lib.makeApps self.nixpkgs;
  };
}
