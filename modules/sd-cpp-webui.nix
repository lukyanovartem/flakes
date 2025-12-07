{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.sd-cpp-webui;
in {
  options.services.sd-cpp-webui = {
    enable = mkEnableOption "sd-cpp-webui service.";
    user = mkOption {
      type = types.str;
      default = "sdcpp";
    };
    group = mkOption {
      type = types.str;
      default = "sdcpp";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/sd-cpp-webui";
    };
    package = mkOption {
      type = types.package;
      default = pkgs.lukyanovartem.sd-cpp-webui;
    };
    port = mkOption {
      type = types.int;
      default = 7860;
    };
    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "sdcpp") {
      sdcpp = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
        createHome = true;
      };
    };
    users.groups = mkIf (cfg.group == "sdcpp") {
      sdcpp = {};
    };
    systemd.services.sd-cpp-webui = {
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${getExe cfg.package}";
        Restart = "on-failure";
        TimeoutSec = 300;
        StartLimitBurst = 10;
        WorkingDirectory = cfg.dataDir;
      };
      environment.GRADIO_SERVER_PORT = toString cfg.port;
      environment.GRADIO_SERVER_NAME = cfg.host;
      wantedBy = [ "multi-user.target" ];
    };
  };
}
