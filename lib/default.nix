{ pkgs }:

with pkgs.lib; {
  mkAfterAfter = mkOrder 1600;
}
