{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      mkPkgs = pkgs: import ./. { inherit pkgs; };
    in
    {
      packages = forAllSystems (system: mkPkgs nixpkgs.legacyPackages.${system});

      overlays = {
        default = final: prev: mkPkgs final;
        scoped = final: prev: {
          nix-kotone.blender-bin = mkPkgs final;
        };
      };
    };
}
