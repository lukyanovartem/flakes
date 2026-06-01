{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages
}:

stdenv.mkDerivation rec {
  pname = "aula-f87-controller";
  version = "unstable-2026-03-02";

  src = fetchFromGitHub {
    owner = "marcoslor";
    repo = "Aula-F87-Controller";
    rev = "de3cbef7d6149c31877ac96bd60d8c71581d301f";
    hash = "sha256-9RAqmcvah1DLEUmOI+xBp7OD+FaIVvRmK4oxmjefmXI=";
    sparseCheckout = [
      "python-cli"
    ];
  };

  setSourceRoot = ''export sourceRoot="$(echo */python-cli)"'';

  nativeBuildInputs = with python3Packages; [ python wrapPython ];

  buildPhase = ''
    chmod +x aula_f87.py
    patchShebangs aula_f87.py
  '';

  installPhase = ''
    mkdir -p $out/${python3Packages.python.sitePackages} $out/bin
    cp -r aula $out/${python3Packages.python.sitePackages}
    cp aula_f87.py $out/bin
  '';

  pythonPath = with python3Packages; [
    hid
  ];

  postFixup = ''
    wrapPythonProgramsIn $out/bin "$out $pythonPath"
  '';

  meta = {
    description = "Controller CLI and HID webapp for the Aula F87 keyboard: https://aula-f87-controller.vercel.app";
    homepage = "https://github.com/marcoslor/Aula-F87-Controller";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "aula_f87.py";
    platforms = lib.platforms.all;
  };
}
