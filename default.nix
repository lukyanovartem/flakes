{ pkgs, wrapWine, ... }:

with pkgs;

rec {
  lib = import ./lib { inherit pkgs; };

  re3 = callPackage ./pkgs/re3 {};
  revc = callPackage ./pkgs/re3/revc.nix { inherit re3; };
  cubesuite = callPackage ./pkgs/cubesuite.nix { inherit wrapWine; };
  aula-keybind = callPackage ./pkgs/aula/aula-keybind.nix {};
  aula-f87-controller = callPackage ./pkgs/aula/aula-f87-controller.nix {};
  snapraid-daemon = callPackage ./pkgs/snapraid-daemon.nix {};
}
