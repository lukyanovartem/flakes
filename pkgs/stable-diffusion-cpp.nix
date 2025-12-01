{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  git, fetchpatch,
  vulkan-loader, vulkan-headers, shaderc, glslang,
}:

stdenv.mkDerivation rec {
  pname = "stable-diffusion-cpp";
  version = "383-20eb674";

  src = fetchFromGitHub {
    owner = "leejet";
    repo = "stable-diffusion.cpp";
    rev = "master-${version}";
    hash = "sha256-9XKoxbBpYcZRL7N7/fpqtJ4kMJlY5NywbiYnfv5W1yk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake git vulkan-headers shaderc glslang
  ];

  buildInputs = [
    vulkan-loader
  ];

  cmakeFlags = [
    "-DSD_VULKAN=ON"
  ];

  meta = {
    description = "Stable Diffusion and Flux in pure C/C";
    homepage = "https://github.com/leejet/stable-diffusion.cpp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sd";
    platforms = lib.platforms.all;
  };
}
