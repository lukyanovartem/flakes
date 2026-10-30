rec {
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  pipewire = ./pipewire.nix;
  vscodium = ./vscodium.nix;
  zsh = ./zsh.nix;
  dashboard = ./dashboard.nix;
  aula = ./aula.nix;
  cache = ./cache.nix;
  snapraid-daemon = ./snapraid-daemon.nix;
  b4 = ./b4.nix;
}
