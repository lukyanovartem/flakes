{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.snapraid-daemon;
  snapraid-daemon = pkgs.lukyanovartem.snapraid-daemon;

  originalFile = readFile "${snapraid-daemon}/etc/snapraidd.conf";
  originalArray = strings.splitString "\n" originalFile;
  hasKey = x: filter (y: hasPrefix y x) (builtins.attrNames cfg.settings);
  commentedArray = concatStringsSep "\n" (map (x: if hasKey x != [] then "#" + x else x) originalArray);
  commentedFile = if cfg.settings == null then originalFile else commentedArray;

  toSettingsFile = key: value:
    let
      value' =
        if isString value then value
        else toString value;
    in
      "${key} = ${value'}";
  settingsFile = concatStringsSep "\n" (mapAttrsToList toSettingsFile cfg.settings);

  configFile = pkgs.writeText "snapraidd.conf" ''
    ${commentedFile}
    ${optionalString (cfg.settings != null) settingsFile}
  '';
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
