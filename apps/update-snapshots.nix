# TODO expose in .#apps.update-snapshots
# Right now this works if you drop it in floxpkgs-internal/apps
{
  writeShellApplication,
  nixeditor,
  alejandra,
  jq,
  ...
}: {
  type = "app";
  program = let
    name = "update-snapshots";
  in
    (writeShellApplication {
      inherit name;
      runtimeInputs = [nixeditor alejandra jq];
      text = ''
        if [ -v DEBUG ]; then set -x; fi

        wd="$1"
        cd "$wd"


        for stability in stable staging unstable; do
            rev=$(jq -r --arg stability "$stability" '(.nodes.root.inputs | .["nixpkgs-"+$stability]) as $nodeName | .nodes | .[$nodeName].locked.rev' flake.lock)
            for system in aarch64-darwin x86_64-linux; do
                url="https://catalog.floxsdlc.com/nixpkgs/$system.$rev.tar.gz"
                sha256=$(nix-prefetch-url --unpack "$url")
                nix-editor flake.nix "outputs.passthru.__pins.snapshots.nixpkgs-$stability.$system" -v "builtins.fetchTarball { url = $url; sha256 = \"$sha256\"; }" -o flake.nix
            done
        done

        alejandra -q flake.nix
      '';
    })
    + "/bin/${name}";
}
