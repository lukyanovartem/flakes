{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.policyfs;
  configFile = builtins.toFile "pfs.yaml" (generators.toYAML { } cfg.settings);
  services = [
    "pfs-maint@"
    "pfs-prune@"
    "pfs-move@"
    "pfs-index@"
  ];
in
{
  options.services.policyfs = {
    enable = mkEnableOption "PolicyFS.";
    settings = mkOption {
      type = types.attrs;
    };
    onCalendar = mkOption {
      type = lib.types.str;
      default = "*-*-* 00:30:00";
    };
  };

  config = mkIf cfg.enable {
    systemd.packages = [ pkgs.lukyanovartem.policyfs ];
    systemd.services = listToAttrs (
      concatMap (
        n:
        [
          {
            name = "pfs@${n}";
            value = {
              overrideStrategy = "asDropin";
              environment.PFS_CONFIG_FILE = configFile;
              wantedBy = [ "multi-user.target" ];
            };
          }
        ]
        ++ (map (n': {
          name = n' + n;
          value = {
            overrideStrategy = "asDropin";
            environment.PFS_CONFIG_FILE = configFile;
          };
        }) services)
      ) (attrNames cfg.settings.mounts)
    );
    systemd.timers = listToAttrs (
      map (n: {
        name = "pfs-maint@${n}";
        value = {
          overrideStrategy = "asDropin";
          timerConfig.OnCalendar = cfg.onCalendar;
          wantedBy = [ "timers.target" ];
        };
      }) (attrNames cfg.settings.mounts)
    );
  };
}
