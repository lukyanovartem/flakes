rec {
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  pipewire = ./pipewire.nix;
  headless = ./headless.nix;
  vscodium = ./vscodium.nix;
  zsh = ./zsh.nix;
  dashboard = ./dashboard.nix;
  sd-cpp-webui = ./sd-cpp-webui.nix;
  aula = ./aula.nix;
}
