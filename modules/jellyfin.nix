{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.jellyfin;
in {
  options.programs.jellyfin = {
    enable = mkEnableOption "jellyfin server";
  };

  config = mkIf cfg.enable {
    services.jellyfin.enable = true;
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
      ];
    };

    services.sonarr.enable = true;
    services.sonarr.group = config.services.transmission.group;
    services.radarr.enable = true;
    services.radarr.group = config.services.transmission.group;
    services.prowlarr.enable = true;
  };
}
