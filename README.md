# 🪇 osu-lazer-flake

![version](https://img.shields.io/badge/version-2026.624.0-blue)

an updated flake for osu!lazer.

## table of contents

- [install](#install)
- [usage](#usage)
  - [nixos](#nixos)
  - [home-manager](#home-manager)
  - [temporary shell](#temporary-shell)
- [flake outputs](#flake-outputs)

## install

add to your `flake.nix` inputs:

```nix
osu-lazer-flake = {
  url = "github:yaaaarn/osu-lazer-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

## usage

### nixos

```nix
environment.systemPackages = [
  inputs.osu-lazer-flake.packages.${system}.default
];
```

### home-manager

```nix
home.packages = [
  inputs.osu-lazer-flake.packages.${system}.default
];
```

### temporary shell

```bash
nix run github:yaaaarn/osu-lazer-flake
```

## flake outputs

| output | description |
|---|---|
| `packages.${system}.default` | osu!lazer binary (AppImage on Linux, .app bundle on macOS) |
| `packages.${system}.osu-lazer-bin` | same as `default`, accessible by name |
| `overlays.default` | nixpkgs overlay exposing `osu-lazer-bin` |
