{ pkgs, wrapWine, ... }:

with pkgs;

rec {
  lib = import ./lib { inherit pkgs; };

  re3 = callPackage ./pkgs/re3.nix {};
  cubesuite = callPackage ./pkgs/cubesuite.nix { inherit wrapWine; };
  modplay = callPackage ./pkgs/modplay.nix {};
  catppuccin = callPackage ./pkgs/catppuccin.nix {};
  stable-diffusion-cpp = callPackage ./pkgs/stable-diffusion-cpp.nix {};
  sd-cpp-webui = callPackage ./pkgs/sd-cpp-webui.nix { inherit stable-diffusion-cpp; };
  emulationstation-de = callPackage ./pkgs/emulationstation-de {};
  aula-keybind = callPackage ./pkgs/aula/aula-keybind.nix {};
  aula-f87-controller = callPackage ./pkgs/aula/aula-f87-controller.nix {};
  yandex-music = callPackage ./pkgs/yandex-music.nix {};
  nirimod = callPackage ./pkgs/nirimod.nix {};
}
