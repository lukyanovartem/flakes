{ pkgs, wrapWine, ... }:

with pkgs;

rec {
  lib = import ./lib { inherit pkgs; };

  re3 = callPackage ./pkgs/re3.nix {};
  cubesuite = callPackage ./pkgs/cubesuite.nix { inherit wrapWine; };
  sd-cpp-webui = callPackage ./pkgs/sd-cpp-webui.nix {};
  emulationstation-de = callPackage ./pkgs/emulationstation-de {};
  aula-keybind = callPackage ./pkgs/aula/aula-keybind.nix {};
  aula-f87-controller = callPackage ./pkgs/aula/aula-f87-controller.nix {};
  nirimod = callPackage ./pkgs/nirimod.nix {};
}
