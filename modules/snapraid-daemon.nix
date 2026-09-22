{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.snapraid-daemon;
  snapraid-daemon = pkgs.lukyanovartem.snapraid-daemon;

  originalFile = readFile "${snapraid-daemon}/etc/snapraidd.conf";
  originalArray = strings.splitString "\n" originalFile;
  hasKey =
    x: filter (y: hasPrefix (y + " ") x || hasPrefix (y + "=") x) (builtins.attrNames cfg.settings);
  commentedArray = concatStringsSep "\n" (
    map (x: if hasKey x != [ ] then "#" + x else x) originalArray
  );
  commentedFile = if cfg.settings == null then originalFile else commentedArray;

  toSettingsFile =
    key: value:
    let
      value' = if isString value then value else toString value;
    in
    "${key} = ${value'}";
  settingsFile = concatStringsSep "\n" (mapAttrsToList toSettingsFile cfg.settings);

  configFile = pkgs.writeText "snapraidd.conf" ''
    ${commentedFile}
    ${optionalString (cfg.settings != null) settingsFile}
  '';
in
{
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
      serviceConfig = {
        ExecStart = [
          ""
          "${getExe snapraid-daemon} -c ${configFile}"
        ];
        ProtectSystem = "full";
        PrivateTmp = "disconnected";
        PrivateMounts = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        RestrictRealtime = true;
        ProtectClock = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
        SocketBindDeny = [ "ipv4:udp" "ipv6:udp" ];
        CapabilityBoundingSet = "~CAP_BLOCK_SUSPEND CAP_BPF CAP_CHOWN CAP_IPC_LOCK CAP_MKNOD CAP_NET_RAW CAP_PERFMON CAP_SYS_BOOT CAP_SYS_CHROOT CAP_SYS_MODULE CAP_SYS_NICE CAP_SYS_PACCT CAP_SYS_PTRACE CAP_SYS_TIME CAP_SYSLOG CAP_WAKE_ALARM";
        SystemCallFilter = "~@aio:EPERM @chown:EPERM @clock:EPERM @cpu-emulation:EPERM @debug:EPERM @keyring:EPERM @memlock:EPERM @module:EPERM @mount:EPERM @obsolete:EPERM @pkey:EPERM @privileged:EPERM @raw-io:EPERM @reboot:EPERM @resources:EPERM @sandbox:EPERM @setuid:EPERM @swap:EPERM";
      };
      wantedBy = [ "multi-user.target" ];
    };

    services.snapraid.enable = true;
    systemd.timers.snapraid-sync.enable = false;
    systemd.timers.snapraid-scrub.enable = false;
  };
}
