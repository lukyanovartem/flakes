{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.snapraid-daemon;
  snapraid-daemon = pkgs.lukyanovartem.snapraid-daemon;
  configFile = pkgs.writeText "snapraidd.conf" ''
    ${builtins.readFile "${snapraid-daemon}/etc/snapraidd.conf"}
    ${optionalString (cfg.settings != null) settingsFile}
  '';
  settingsFile = (concatStringsSep "\n" (mapAttrsToList toSettingsFile cfg.settings));
  toSettingsFile = key: value:
    let
      value' =
        if isString value then value
        else toString value;
    in
      "${key} = ${value'}";
in {
  options.services.snapraid-daemon = {
    enable = mkEnableOption "SnapRAID Daemon.";
    configFile = mkOption {
      type = with types; nullOr str;
      default = null;
    };
    settings = mkOption {
      type = with types; nullOr attrs;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    systemd.packages = [ snapraid-daemon ];
    systemd.services.snapraidd = {
      serviceConfig.ExecStart = [ "" "${getExe snapraid-daemon} -c ${configFile}" ];
      wantedBy = [ "multi-user.target" ];
    };

    services.snapraid.enable = true;
    systemd.timers.snapraid-sync.enable = false;
    systemd.timers.snapraid-scrub.enable = false;
  };
}
