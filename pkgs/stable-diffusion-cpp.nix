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
  version = "10feacf";

  src = fetchFromGitHub {
    owner = "leejet";
    repo = "stable-diffusion.cpp";
    rev = "master-${version}";
    hash = "sha256-LrWS16rddPqJJc+73/6mNqWdweAd0ZboxI5m1rvIxtA=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/leejet/stable-diffusion.cpp/pull/484.patch";
      hash = "sha256-VapHVytOgJEMKUG9EECZChpcD3CrauYcAnl21PNrxo4=";
    })
  ];

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
