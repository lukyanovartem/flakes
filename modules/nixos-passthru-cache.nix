# https://github.com/numtide/nixos-passthru-cache

{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.nixos-passthru-cache;
in
{
  options = {
    services.nixos-passthru-cache = {
      enable = lib.mkEnableOption "Enable NixOS passthru cache";
      upstream = lib.mkOption {
        type = lib.types.str;
        default = "https://cache.nixos.org";
        description = "Upstream binary cache URL to proxy (scheme+host, optional port/path).";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 5000;
      };
      cacheSize = lib.mkOption {
        type = lib.types.str;
        description = "Size of the cache";
      };
      inactivity = lib.mkOption {
        type = lib.types.str;
        description = "Time before cache is considered inactive";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedOptimisation = lib.mkDefault true;
      recommendedProxySettings = lib.mkDefault true;
      additionalModules = [ pkgs.nginxModules.vts ];
      # Add HTTP-level VTS shared memory zone
      appendHttpConfig = ''
        vhost_traffic_status_zone;
      '';
      proxyCachePath."nixos-passthru-cache" = {
        enable = true;
        levels = "1:2";
        keysZoneName = "nixos-passthru-cache";
        maxSize = cfg.cacheSize;
        inactive = cfg.inactivity;
        useTempPath = false;
      };

      # TODO: test if this improves performance
      appendConfig = ''
        worker_processes auto;
      '';
      resolver.addresses =
        let
          isIPv6 = addr: builtins.match ".*:.*:.*" addr != null;
          escapeIPv6 = addr: if isIPv6 addr then "[${addr}]" else addr;
          cloudflare = [
            "1.1.1.1"
            "2606:4700:4700::1111"
          ];
          resolvers =
            if config.networking.nameservers == [ ] then cloudflare else config.networking.nameservers;
        in
        map escapeIPv6 resolvers;
    };

    services.nginx.virtualHosts."nixos-passthru-cache" = {
      listen = [{ addr = "0.0.0.0"; port = cfg.port; }];
      locations."=/" = {
        extraConfig = ''
          return 301 /status;
        '';
      };
      locations."=/nix-cache-info" = {
        root = pkgs.writeTextDir "nix-cache-info" ''
          StoreDir: /nix/store
          WantMassQuery: 1
          Priority: 40
          Allow: *
        '';
        extraConfig = ''
          add_header Content-Type text/x-nix-cache-info;
        '';
      };
      # VTS status page
      locations."/status" = {
        extraConfig = ''
          vhost_traffic_status_display;
          vhost_traffic_status_display_format html;
        '';
      };
      locations."/" = {
        recommendedProxySettings = false;
        proxyPass = cfg.upstream;
        extraConfig = ''
          proxy_cache nixos-passthru-cache;
          proxy_cache_use_stale error timeout http_500 http_502 http_503 http_504;
          proxy_cache_valid 200 ${cfg.inactivity};
          proxy_cache_valid 404 1m;

          # Proxy headers - fixed syntax
          proxy_set_header Host "${
            let
              # Extract host[:port] from URL
              m = builtins.match "^[a-zA-Z0-9+.-]+://([^/]+).*" cfg.upstream;
            in
            if m == null then cfg.upstream else builtins.head m
          }";
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_http_version 1.1;

          # To address "could not build optimal proxy_headers_hash..."
          proxy_headers_hash_max_size 512;
          proxy_headers_hash_bucket_size 128;

          # Timeouts
          proxy_connect_timeout 60s;
          proxy_send_timeout 60s;
          proxy_read_timeout 60s;

          # Buffer settings
          proxy_buffering on;
          proxy_buffer_size 16k;
          proxy_buffers 4 32k;
          proxy_busy_buffers_size 64k;

          # Optional: Add custom headers
          add_header X-Cache-Status $upstream_cache_status;
        '';
      };
    };

  };
}
