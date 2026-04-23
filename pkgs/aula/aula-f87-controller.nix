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
    rev = "04c1388ffae69828dba12d750d545c69770b8fc0";
    hash = "sha256-ZzmQxLoiiRRIvDT62TmxSjfX7pZ3RIwZMbrg+3F7AMI=";
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
