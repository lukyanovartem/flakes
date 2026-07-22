rec {
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  pipewire = ./pipewire.nix;
  headless = ./headless.nix;
  vscodium = ./vscodium.nix;
  zsh = ./zsh.nix;
  dashboard = ./dashboard.nix;
  aula = ./aula.nix;
  cache = ./cache.nix;
  snapraid-daemon = ./snapraid-daemon.nix;
}
