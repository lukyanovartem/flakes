{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages, stable-diffusion-cpp-vulkan, pciutils, which
}:

stdenv.mkDerivation rec {
  pname = "sd-cpp-webui";
  version = "unstable-2026-05-23";

  src = fetchFromGitHub {
    owner = "daniandtheweb";
    repo = "sd.cpp-webui";
    rev = "fac4149aa9c59619bcca9514486b80f6db833350";
    hash = "sha256-azXNcPoNwfha1h3hw00lu6K0REu98cCtQSTMXTl6uaA=";
  };

  nativeBuildInputs = with python3Packages; [ wrapPython ];

  installPhase = ''
    mkdir -p $out/${python3Packages.python.sitePackages}
    cp -r modules $out/${python3Packages.python.sitePackages}
    install -Dm755 sdcpp_webui.py $out/bin/sdcpp_webui
  '';

  pythonPath = with python3Packages; [ gradio pciutils which stable-diffusion-cpp-vulkan ];
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
