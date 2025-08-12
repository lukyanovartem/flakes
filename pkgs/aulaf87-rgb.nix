{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "aulaf87-rgb";
  version = "unstable-2025-08-09";

  src = fetchFromGitHub {
    owner = "lukyanovartem";
    repo = "drivers";
    rev = "76c6a491655ed6037ad83f75e44786b47023fbbf";
    hash = "sha256-OBZ0Ntv0j9GfotOOaRRMOL76RiRduzDEDSVUm0gKLK4=";
    sparseCheckout = [
      pname
    ];
  };

  setSourceRoot = ''export sourceRoot="$(echo */${pname})"'';
  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  meta = {
    description = "Control of Aula F87 keyboard leds";
    homepage = "https://github.com/lukyanovartem/drivers/tree/master/aulaf87-rgb";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ ];
    mainProgram = pname;
    platforms = lib.platforms.linux;
  };
}
