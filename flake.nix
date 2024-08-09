{
  description = "fast moving flake for nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pixi-source.url = "github:prefix-dev/pixi/v0.27.1";
    pixi-source.flake = false;
  };

  outputs =
    {
      self,
      nixpkgs,
      pixi-source,
    }:
    let
      inherit (nixpkgs.lib) genAttrs;
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        genAttrs supportedSystems (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            }
          )
        );
    in
    {
      overlays = {
        default = (final: prev: { pixi = final.callPackage ./package.nix { inherit pixi-source; }; });
      };

      packages = forAllSystems (pkgs: {
        default = self.packages.${pkgs.system}.pixi;
        pixi = pkgs.pixi;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
