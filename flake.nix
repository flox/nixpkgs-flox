{
  inputs.nixpkgs.url = "github:flox/nixpkgs/staging";
  inputs.capacitor.url = "github:flox/capacitor";

  outputs = {self, nixpkgs, capacitor}:
  let
    capacitor-apps = capacitor.lib.makeApps combined nixpkgs;
    combined = nixpkgs.lib.recursiveUpdate nixpkgs capacitor-apps;
  in
    combined;
}
