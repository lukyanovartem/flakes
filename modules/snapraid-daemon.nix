{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.snapraid-daemon;
  snapraid-daemon = pkgs.lukyanovartem.snapraid-daemon;
in {
  options.services.snapraid-daemon = {
    enable = mkEnableOption "SnapRAID Daemon.";
  };

  config = mkIf cfg.enable {
    systemd.packages = [ snapraid-daemon ];
    systemd.services.snapraidd.wantedBy = [ "multi-user.target" ];
    system.activationScripts.snapraid-daemon = ''
      if [ ! -f "/etc/snapraidd.conf" ]; then
        cp ${snapraid-daemon}/etc/snapraidd.conf /etc
      fi
    '';

    services.snapraid.enable = true;
    systemd.timers.snapraid-sync.enable = false;
    systemd.timers.snapraid-scrub.enable = false;
  };
}
