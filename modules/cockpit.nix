{ config, lib, pkgs, ... }:

with lib;
let
  cpkgs = pkgs.lukyanovartem;
  cfg = config.programs.cockpit;
in {
  options.programs.cockpit = {
    enable = mkEnableOption ''
      Cockpit with cockpit-machines
    '';
  };

  config = mkIf cfg.enable {
    services.cockpit.enable = true;
    services.cockpit.port = 9092;
    services.cockpit.settings = {
      WebService = {
        AllowUnencrypted = true;
      };
    };

    environment.systemPackages = with pkgs; with cpkgs; [ cockpit-machines libvirt-dbus ];
    programs.virt-manager.enable = lib.mkDefault true;
  };
}
