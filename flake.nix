{
  description = "An updated flake for osu!lazer";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      osu-lazer-bin = pkgs.callPackage ./package.nix { };
    in
    {
      packages.${system} = {
        default = osu-lazer-bin;
        osu-lazer-bin = osu-lazer-bin;
      };

      overlays.default = final: prev: {
        osu-lazer-bin = if prev.stdenv.hostPlatform.system == system then self.packages.${system}.osu-lazer-bin else prev.osu-lazer-bin;
      };
    };
}
