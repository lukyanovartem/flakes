{ pkgs, wrapWine, ... }:

with pkgs;

rec {
  lib = import ./lib { inherit pkgs; };

  re3 = callPackage ./pkgs/re3 {};
  revc = callPackage ./pkgs/re3/revc.nix { inherit re3; };
  cubesuite = callPackage ./pkgs/cubesuite.nix { inherit wrapWine; };
  aula-f87pro-linux = callPackage ./pkgs/aula-f87pro-linux {};
  snapraid-daemon = callPackage ./pkgs/snapraid-daemon.nix {};
  b4 = callPackage ./pkgs/b4.nix {};
}
