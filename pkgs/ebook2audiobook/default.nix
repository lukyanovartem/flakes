{ python312, callPackage }:

let
  python = python312.override {
    packageOverrides = self: super: {
      iso639-lang = self.callPackage ./iso639-lang.nix {};
      coqui-tts = self.callPackage ./coqui-tts.nix {};
      torch = super.torch.override { rocmSupport = true; };
      torchcodec = super.torchcodec.override { torch = super.torch // {
        lib = (super.torch.override { rocmSupport = true; }).lib;
        dev = (super.torch.override { rocmSupport = false; }).dev; };
      };
      pyannote-audio = super.pyannote-audio.overrideAttrs (oldAttrs: {
        dontUsePythonCatchConflicts = true;
      });
    };
  };
in callPackage ./ebook2audiobook.nix { python3Packages = python.pkgs; }
