{ python3, callPackage }:

let
  python = python3.override {
    packageOverrides = self: super: {
      vocos = self.callPackage ./vocos.nix {};
      torch = super.torch.override { rocmSupport = true; };
    };
  };
in callPackage ./fb2tts.nix { python3Packages = python.pkgs; }
