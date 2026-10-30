{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.b4;
  nft = pkgs.writeShellApplication {
    name = "nft";
    text = ''
      /run/wrappers/bin/sudo ${lib.getExe pkgs.nftables} "$@"
    '';
  };
in
{
  options.services.b4 = {
    enable = mkEnableOption "b4.";
    extraOpts = lib.mkOption {
      default = "";
      type = lib.types.separatedString " ";
    };
  };

  config = mkIf cfg.enable {
    security.sudo.extraRules = [
      {
        users = [ "b4" ];
        commands = [
          {
            command = "${lib.getExe pkgs.nftables}";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
    users.users.b4 = {
      group = "b4";
      isSystemUser = true;
    };
    users.groups.b4 = { };
    systemd.services."b4" = {
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ nft ];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.lukyanovartem.b4} --config=/var/lib/b4/b4.json ${cfg.extraOpts}";
        User = "b4";
        Group = "b4";
        StateDirectory = "b4";
        ProtectSystem = "full";
        PrivateTmp = "disconnected";
        PrivateDevices = true;
        PrivateMounts = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        RestrictRealtime = true;
        ProtectClock = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK AF_UNIX";
        SocketBindDeny = ["ipv4:udp" "ipv6:udp" ];
        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_RAW CAP_SETUID CAP_SETGID";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_RAW CAP_SETUID CAP_SETGID ~CAP_BLOCK_SUSPEND CAP_BPF CAP_CHOWN CAP_IPC_LOCK CAP_MKNOD CAP_PERFMON CAP_SYS_BOOT CAP_SYS_CHROOT CAP_SYS_MODULE CAP_SYS_NICE CAP_SYS_PACCT CAP_SYS_PTRACE CAP_SYS_TIME CAP_SYSLOG CAP_WAKE_ALARM";
        # @privileged:EPERM @resources:EPERM @setuid:EPERM
        SystemCallFilter = "~@aio:EPERM @chown:EPERM @clock:EPERM @cpu-emulation:EPERM @debug:EPERM @keyring:EPERM @memlock:EPERM @module:EPERM @mount:EPERM @obsolete:EPERM @pkey:EPERM @raw-io:EPERM @reboot:EPERM @sandbox:EPERM @swap:EPERM";
      };
    };
  };
}
