{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.services.cache;
in
{
  options.services.cache = {
    enable = mkEnableOption "p2p binary cache.";
    hosts = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
    port = mkOption {
      type = types.int;
      default = 5001;
    };
  };

  config = mkIf cfg.enable {
    services.nix-serve.enable = true;
    services.nginx = {
      enable = true;
      virtualHosts."nix-serve" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = cfg.port;
          }
        ];
        locations =
          (listToAttrs (
            map (x: {
              name = "/${x}/";
              value = {
                proxyPass = "http://${x}:${toString config.services.nix-serve.port}/";
                extraConfig = ''
                  proxy_connect_timeout 1s;
                  error_page 504 =404 /;
                '';
              };
            }) cfg.hosts
          ))
          // (listToAttrs (
            map (x: {
              name = "=/${x}/nix-cache-info";
              value = {
                proxyPass = "http://127.0.0.1:${toString config.services.nix-serve.port}/nix-cache-info";
              };
            }) cfg.hosts
          ));
      };
    };
    nix.settings.substituters = map (x: "http://localhost:${toString cfg.port}/${x}/") cfg.hosts;
  };
}
