{ pkgs, wrapWine, ... }:

with pkgs;

rec {
  lib = import ./lib { inherit pkgs; };

  re3 = callPackage ./pkgs/re3.nix {};
  cubesuite = callPackage ./pkgs/cubesuite.nix { inherit wrapWine; };
  modplay = callPackage ./pkgs/modplay.nix {};
  catppuccin = callPackage ./pkgs/catppuccin.nix {};
  aulaf87-rgb = callPackage ./pkgs/aulaf87-rgb.nix {};
  stable-diffusion-cpp = callPackage ./pkgs/stable-diffusion-cpp.nix {};
  sd-cpp-webui = callPackage ./pkgs/sd-cpp-webui.nix { inherit stable-diffusion-cpp; };
  emulationstation-de = callPackage ./pkgs/emulationstation-de {};
  ebook2audiobook = callPackage ./pkgs/ebook2audiobook {};
}
