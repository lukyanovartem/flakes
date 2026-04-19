{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.dms;
  format = pkgs.formats.json { };
  configFile = pkgs.writeText "config.json" (builtins.toJSON cfg.settings);
in {
  options.services.dms = {
    enable = mkEnableOption "DMS";
    settings = mkOption {
      type = format.type;
      default = {};
    };
    port = mkOption {
      type = types.int;
      default = 1338;
    };
  };

  config = mkIf cfg.enable {
    users.users.dms = {
      group = "dms";
      home = "/var/lib/dms";
      isSystemUser = true;
      createHome = true;
    };
    users.groups.dms = {};
    systemd.services.dms = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = with pkgs; [ ffmpeg ffmpegthumbnailer ];
      serviceConfig = {
        User = "dms";
        Group = "dms";
        ExecStart = "${lib.getExe pkgs.dms} -config ${configFile} -http :${toString cfg.port}";
        WorkingDirectory = "/var/lib/dms";
      };
    };
  };
}
