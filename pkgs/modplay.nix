{ stdenv, lib, fetchFromGitHub, makeWrapper, installShellFiles
, coreutils, curl, dtrx, uade123, libopenmpt, sidplayfp, libnotify }:

stdenv.mkDerivation rec {
  pname = "modplay";
  version = "2025-08-09";

  src = fetchFromGitHub {
    owner = "lukyanovartem";
    repo = "scripts";
    rev = "652e6cc633b8fbfd72e7778a1b34a36e896a1304";
    sha256 = "sha256-JlkwiaM1TKl+V51mycJH4GTSjg+HMA7rO61FJjihstg=";
    sparseCheckout = [
      pname
    ];
  };

  buildInputs = [ makeWrapper ];
  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    installBin ${pname}/modplay.sh
    installBin ${pname}/modplay-shuffle.sh
    wrapProgram $out/bin/modplay.sh \
      --prefix PATH : ${lib.makeBinPath [ coreutils curl dtrx uade123 libopenmpt sidplayfp libnotify ]}
  '';

  meta = with lib; {
    description = "A quick hack to play tracker music on *nix";
    license = licenses.free;
    homepage = "https://github.com/lukyanovartem/scripts/tree/master/modplay";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
