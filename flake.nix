{
  description = "fast moving flake for nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pixi-source.url = "github:prefix-dev/pixi";
    pixi-source.flake = false;
  };

  outputs =
    {
      self,
      nixpkgs,
      pixi-source,
    }:
    let

      inherit (nixpkgs.lib) genAttrs fakeHash;
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

        default = (
          final: prev: {
            pixi = prev.pixi.overrideAttrs (oldAttrs: rec {
              pname = "pixi";
              version = "0.20.1";

              src = final.fetchFromGitHub {
                owner = "prefix-dev";
                repo = "pixi";
                # rev = "v${version}";
                rev = "v0.20.1";
                hash = "sha256-//AAKEVeafue9tVEVWAwJl/+uXIvo20qv8ktSIRsMzs=";
              };
              cargoDeps = final.rustPlatform.importCargoLock {
                lockFile = "${pixi-source}/Cargo.lock";
                outputHashes = {
                  "async_zip-0.0.17" = "sha256-Q5fMDJrQtob54CTII3+SXHeozy5S5s3iLOzntevdGOs=";
                  "cache-key-0.0.1" = "sha256-XsBTfe2+J5CGdjYZjhgxiP20OA7+VTCvD9JniLOjhKs=";
                  "pubgrub-0.2.1" = "sha256-sqC7R2mtqymYFULDW0wSbM/MKCZc8rP7Yy/gaQpjYEI=";
                };
              };
            });
          }
        );
      };

      packages = forAllSystems (pkgs: {
        default = self.packages.${pkgs.system}.pixi;
        pixi = pkgs.pixi;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
