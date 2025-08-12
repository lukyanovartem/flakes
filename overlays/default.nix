{ pkgs, config ? null }:

self: super: with super.lib;
rec {
} // optionalAttrs (config.hardware.regdomain.enable or false) {
  inherit (pkgs.lukyanovartem) wireless-regdb;
  crda = super.crda.overrideAttrs (oldAttrs: rec {
    makeFlags = oldAttrs.makeFlags ++ [
      "PUBKEY_DIR=${pkgs.lukyanovartem.wireless-regdb}/lib/crda/pubkeys"
    ];
  });
}
