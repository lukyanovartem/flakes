{ lib, stdenv, fetchurl, fetchgit, premake5, glfw, openal, mpg123, libsndfile, installShellFiles, makeWrapper, makeDesktopItem }:

let
  re3 = makeDesktopItem rec {
    name = "re3";
    exec = name;
    icon = name;
    comment = "Grand Theft Auto III";
    genericName = comment;
    desktopName = name;
    categories = [ "Game" ];
  };
in stdenv.mkDerivation rec {
  pname = "re3";
  version = "1.0";

  src' = fetchurl {
    url = "https://archive.org/download/github.com-GTAmodding-re3_-_2021-09-06_14-11-00/GTAmodding-re3_-_2021-09-06_14-11-00.bundle";
    sha256 = "sha256-A1y19ZgRrghlEPAr04F+r0OTPJcj5S26YIB/SMTp2cM=";
  };

  src = fetchgit {
    url = src';
    sha256 = "sha256-WCvs5QGkfnj33yu26LdSVTtwhuLyB3NhkT1i1nirvCk=";
    fetchSubmodules = true;
  };

  buildInputs = [ glfw openal mpg123 libsndfile ];
  nativeBuildInputs = [ premake5 installShellFiles makeWrapper ];

  preConfigure = ''
    patchShebangs printHash.sh
  '';

  buildPhase = ''
    premake5 --with-librw gmake2
    cd build
    make config=release_linux-amd64-librw_gl3_glfw-oal
  '';

  installPhase = ''
    installBin ../bin/linux-amd64-librw_gl3_glfw-oal/Release/re3
    mkdir -p $out/share/games/re3
    cp -r ../gamefiles $out/share/games/re3
    install -Dm644 ../res/images/logo.svg "$out/share/pixmaps/re3.svg"
    wrapProgram $out/bin/re3 \
      --run "cd ~/.config/re3"
    mkdir -p $out/share/applications
    ln -s ${re3}/share/applications/* $out/share/applications
  '';
  meta = with lib; {
    description = "GTA III engine";
    license = licenses.unfree;
    homepage = "https://archive.org/details/github.com-GTAmodding-re3_-_2021-09-06_14-11-00";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
