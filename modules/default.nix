rec {
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  pipewire = ./pipewire.nix;
  headless = ./headless.nix;
  vscodium = ./vscodium.nix;
  udisks = ./udisks.nix;
  theme = ./theme.nix;
  jellyfin = ./jellyfin.nix;
  catppuccin = ./catppuccin.nix;
  zsh = ./zsh.nix;
  dashboard = ./dashboard.nix;
  aulaf87-rgb = ./aulaf87-rgb.nix;
  sd-cpp-webui = ./sd-cpp-webui.nix;
  nixos-passthru-cache = ./nixos-passthru-cache.nix;
}
