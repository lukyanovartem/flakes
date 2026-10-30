{ re3, fetchurl, fetchgit }:

re3.overrideAttrs (oldAttrs: rec {
  src' = fetchurl {
    url = "https://archive.org/download/github.com-GTAmodding-re3_-_2021-09-06_14-11-00/GTAmodding-re3_-_2021-09-06_14-11-00.bundle";
    sha256 = "sha256-A1y19ZgRrghlEPAr04F+r0OTPJcj5S26YIB/SMTp2cM=";
  };

  src = fetchgit {
    url = src';
    rev = "a16fcd8d6a79e433c1c6e73d540f1bbe27e14164";
    sha256 = "sha256-VlDLAptJ4eRzyjtTfHwsvqAvHsRDbYfadPV1uR8nkZU=";
    fetchSubmodules = true;
  };

  installPhase = ''
    installBin ../bin/linux-amd64-librw_gl3_glfw-oal/Release/reVC
    mkdir -p $out/share/games/revc
    cp -r ../gamefiles $out/share/games/revc
  '';
})