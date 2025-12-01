{ stdenv, lib, buildNpmPackage, fetchFromGitHub, python3Packages
, makeWrapper, ffmpeg }:

let
  version = "2025.11.29";
  src = fetchFromGitHub {
    owner = "alexta69";
    repo = "metube";
    rev = "${version}";
    hash = "sha256-iFVQHuWuGq261YGoEj5BjgVPzwGcveJGG8NohHS9D8I=";
  };
  metube_ui = buildNpmPackage rec {
    pname = "metube-ui";
    inherit version src;
    sourceRoot = "source/ui";
    npmDepsHash = "sha256-rnZqWcpklOPFlEVnj5w73Uh17hRBeWKP+P1jn8aQC0w=";
  };
in stdenv.mkDerivation rec {
  pname = "metube";
  inherit version src;

  nativeBuildInputs = with python3Packages; [ wrapPython makeWrapper ];

  pythonPath = with python3Packages; [ pylint aiohttp python-socketio yt-dlp watchfiles ];

  postFixup = ''
    mkdir -p $out/app $out/ui $out/bin
    cp -r app/* $out/app
    chmod +x $out/app/main.py
    sed -i '1i #!/usr/bin/env python3' $out/app/dl_formats.py $out/app/ytdl.py
    substituteInPlace $out/app/main.py \
      --replace-fail "ui/dist/metube" "$out/ui/dist/metube"
    cp -r ${metube_ui}/lib/node_modules/metube/dist $out/ui
    wrapPythonProgramsIn $out/app "$out $pythonPath"
    makeWrapper $out/app/main.py $out/bin/metube \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]} \
      --set METUBE_VERSION ${version}
  '';

  meta = {
    description = "Self-hosted YouTube downloader (web UI for youtube-dl / yt-dlp)d";
    homepage = "https://github.com/alexta69/metube";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "metube";
  };
}
