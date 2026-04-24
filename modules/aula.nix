{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.aula;
  format = pkgs.formats.json { };
  keys = pkgs.writeText "keys.json" (builtins.toJSON cfg.keys);
  leds = concatStringsSep " " (mapAttrsToList (name: value: "${name}:${value}") cfg.leds);
in {
  options.services.aula = {
    enable = mkEnableOption "Aula F87 support";
    keys = mkOption {
      type = format.type;
      default = {};
    };
    leds = mkOption {
      type = types.attrs;
      default = {};
    };
    applyOnChange = mkEnableOption "applying changes to firmware on config changes";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs.lukyanovartem; [ aula-keybind aula-f87-controller ];

    # wine OemDrv.exe for factory reset
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="010c", MODE="0666"
      KERNEL=="hidraw*", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="010c", MODE="0666"
    '';

    systemd.services.aula-keybind = {
      wantedBy = [ "multi-user.target" ];
      reloadIfChanged = cfg.applyOnChange;
      serviceConfig = {
        RemainAfterExit = true;
        ExecReload = "${getExe pkgs.lukyanovartem.aula-keybind} bind import ${keys}";
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
        ExecReload = "${getExe pkgs.lukyanovartem.aula-f87-controller} perkey ${leds}";
      };
      script = ''
        exit 0
      '';
    };
  };
}
