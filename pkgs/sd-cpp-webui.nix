{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages, stable-diffusion-cpp, pciutils
}:

stdenv.mkDerivation rec {
  pname = "sd-cpp-webui";
  version = "unstable-2025-11-20";

  src = fetchFromGitHub {
    owner = "daniandtheweb";
    repo = "sd.cpp-webui";
    rev = "67cbe425839f36999808acbd2342bcc9b2ac017d";
    hash = "sha256-smXfTR26BDYsnyQKuqJ0/ONUMlEWOvszlmTxFnnyBnA=";
  };

  nativeBuildInputs = with python3Packages; [ wrapPython ];

  buildPhase = ''
    substituteInPlace modules/utils/sd_interface.py \
      --replace-fail "./sd" "${lib.getExe stable-diffusion-cpp}"
  '';

  installPhase = ''
    mkdir -p $out/${python3Packages.python.sitePackages}
    cp -r modules $out/${python3Packages.python.sitePackages}
    install -Dm755 sdcpp_webui.py $out/bin/sdcpp_webui
  '';

  pythonPath = with python3Packages; [ gradio pciutils ];
  postFixup = ''
    wrapPythonProgramsIn $out/bin "$out $pythonPath"
  '';

  meta = {
    description = "A simple webui for stable-diffusion.cpp";
    homepage = "https://github.com/daniandtheweb/sd.cpp-webui";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sdcpp_webui";
    platforms = lib.platforms.all;
  };
}
