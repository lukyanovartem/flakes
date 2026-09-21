{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.hardware.aula;
  format = pkgs.formats.json { };
  keys = pkgs.writeText "keys.json" (builtins.toJSON cfg.keys);
  leds = pkgs.writeShellScript "leds" ''
    args="${concatStringsSep " " (mapAttrsToList (name: value: "${name}:${value}") cfg.leds)}"
    ${getExe pkgs.lukyanovartem.aula-f87-controller} perkey $args
  '';
in
{
  options.hardware.aula = {
    enable = mkEnableOption "Aula F87 support";
    keys = mkOption {
      type = format.type;
      default = { };
    };
    leds = mkOption {
      type = types.attrs;
      default = { };
    };
    applyOnChange = mkEnableOption "applying changes to firmware on config changes";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs.lukyanovartem; [
      aula-keybind
      aula-f87-controller
    ];

    # wine OemDrv.exe for factory reset
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "70-aula.rules";
        destination = "/etc/udev/rules.d/70-aula.rules";
        text = ''
          KERNEL=="hidraw*", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="010c", MODE="0660", GROUP="input", TAG+="uaccess"
          KERNEL=="hidraw*", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="010d", MODE="0660", GROUP="input", TAG+="uaccess"
          SUBSYSTEM=="usb", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="010c", MODE="0660", GROUP="input", TAG+="uaccess"
          SUBSYSTEM=="usb", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="010d", MODE="0660", GROUP="input", TAG+="uaccess"
        '';
        checkPhase = ''
          ${config.systemd.package}/bin/udevadm verify --resolve-names=late $out/etc/udev/rules.d/70-aula.rules
        '';
      })
    ];

    systemd.services.aula-keybind = {
      wantedBy = [ "multi-user.target" ];
      reloadIfChanged = cfg.applyOnChange;
      serviceConfig = {
        RemainAfterExit = true;
        ExecReload = "${getExe pkgs.lukyanovartem.aula-keybind} bind import ${keys}";
        DynamicUser = true;
        Group = "input";
        StateDirectory = "aula-keybind";
        Environment = "HOME=/var/lib/aula-keybind";
        ProtectSystem = "full";
        ProtectHome = true;
        PrivateTmp = "disconnected";
        PrivateMounts = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectProc = "ptraceable";
        LockPersonality = true;
        RestrictRealtime = true;
        ProtectClock = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_NETLINK AF_UNIX";
        SocketBindDeny = [
          "ipv4:tcp"
          "ipv4:udp"
          "ipv6:tcp"
          "ipv6:udp"
        ];
        CapabilityBoundingSet = "~CAP_BLOCK_SUSPEND CAP_BPF CAP_CHOWN CAP_IPC_LOCK CAP_MKNOD CAP_NET_RAW CAP_PERFMON CAP_SYS_BOOT CAP_SYS_CHROOT CAP_SYS_MODULE CAP_SYS_NICE CAP_SYS_PACCT CAP_SYS_PTRACE CAP_SYS_TIME CAP_SYSLOG CAP_WAKE_ALARM";
        SystemCallFilter = "~@aio:EPERM @chown:EPERM @clock:EPERM @cpu-emulation:EPERM @debug:EPERM @ipc:EPERM @keyring:EPERM @memlock:EPERM @module:EPERM @mount:EPERM @obsolete:EPERM @pkey:EPERM @privileged:EPERM @raw-io:EPERM @reboot:EPERM @resources:EPERM @sandbox:EPERM @setuid:EPERM @swap:EPERM";
      };
      script = ''
        exit 0
      '';
    };

    systemd.services.aula-f87-controller = {
      wantedBy = [ "multi-user.target" ];
      reloadIfChanged = cfg.applyOnChange;
      serviceConfig = {
        RemainAfterExit = true;
        ExecReload = leds;
        DynamicUser = true;
        Group = "input";
        ProtectSystem = "strict";
        ProtectHome = true;
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
        RestrictAddressFamilies = "AF_UNIX";
        SocketBindDeny = [
          "ipv4:tcp"
          "ipv4:udp"
          "ipv6:tcp"
          "ipv6:udp"
        ];
        CapabilityBoundingSet = "~CAP_BLOCK_SUSPEND CAP_BPF CAP_CHOWN CAP_IPC_LOCK CAP_MKNOD CAP_NET_RAW CAP_PERFMON CAP_SYS_BOOT CAP_SYS_CHROOT CAP_SYS_MODULE CAP_SYS_NICE CAP_SYS_PACCT CAP_SYS_PTRACE CAP_SYS_TIME CAP_SYSLOG CAP_WAKE_ALARM";
        SystemCallFilter = "~@aio:EPERM @chown:EPERM @clock:EPERM @cpu-emulation:EPERM @debug:EPERM @ipc:EPERM @keyring:EPERM @memlock:EPERM @module:EPERM @mount:EPERM @obsolete:EPERM @pkey:EPERM @privileged:EPERM @raw-io:EPERM @reboot:EPERM @resources:EPERM @sandbox:EPERM @setuid:EPERM @swap:EPERM";
      };
      script = ''
        exit 0
      '';
    };
  };
}
