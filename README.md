Personal flakes repository

# Required
```nix
imports = [ flakes.nixosModules.default ];
```
# Packages
```nix
environment.systemPackages = with pkgs; [ lukyanovartem.<package> ];
```
# Modules
```nix
imports = [ flakes.nixosModules.<module> ];
```
# Overlays
```nix
nixpkgs.overlays = [ (flakes.overlays.default { inherit config; }) ];
```