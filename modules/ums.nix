{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.ums;
in {
  options.services.ums = {
    enable = mkEnableOption "ums service.";
    user = mkOption {
      type = types.str;
      default = "ums";
    };
    group = mkOption {
      type = types.str;
      default = "ums";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/ums";
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "ums") {
      ums = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
        createHome = true;
      };
    };
    users.groups = mkIf (cfg.group == "ums") {
      ums = {};
    };
    systemd.services.ums = {
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = getExe pkgs.ums;
        Restart = "on-failure";
        TimeoutSec = 300;
        StartLimitBurst = 10;
      };
      path = with pkgs; [ ffmpeg iputils ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
