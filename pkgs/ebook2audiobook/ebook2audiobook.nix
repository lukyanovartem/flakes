{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages, rsync, calibre, ffmpeg
}:

let
  ebook2audiobook-run = ''
    ${lib.getExe rsync} -a ${placeholder "out"}/ebook2audiobook/ ~/.ebook2audiobook
    chmod -R +w ~/.ebook2audiobook
    cd ~/.ebook2audiobook
  '';
in stdenv.mkDerivation rec {
  pname = "ebook2audiobook";
  version = "25.12.13";

  src = fetchFromGitHub {
    owner = "DrewThomasson";
    repo = "ebook2audiobook";
    rev = "v${version}";
    hash = "sha256-uc84GQ0LJJ6f68JeCG04+9A0k1Eup8TOgaT9DWp0HRc=";
  };

  nativeBuildInputs = with python3Packages; [ python wrapPython ];

  buildPhase = ''
    sed -i '1 i\#!/usr/bin/env python' app.py
    chmod +x app.py
    patchShebangs app.py
    substituteInPlace app.py \
      --replace-fail "manager.install_python_packages()" "False" \
      --replace-fail "server_port=interface_port," "" \
      --replace-fail "is_port_in_use(interface_port)" "False"
    substituteInPlace lib/conf.py \
      --replace-fail "\"CUDA\": {\"proc\": \"cuda\", \"found\": False}" "\"CUDA\": {\"proc\": \"cuda\", \"found\": True}"
  '';

  installPhase = ''
    mkdir -p $out/ebook2audiobook
    cp -r * $out/ebook2audiobook
    mkdir -p $out/${python3Packages.python.sitePackages} $out/bin
    mv $out/ebook2audiobook/lib $out/${python3Packages.python.sitePackages}
    mv $out/ebook2audiobook/app.py $out/bin/ebook2audiobook
  '';

  pythonPath = with python3Packages; [
    pytesseract uvicorn pymupdf ebooklib gradio psutil stanza beautifulsoup4
    iso639-lang num2words langdetect unidecode phonemizer scipy soundfile
    librosa pyannote-audio coqui-tts mutagen
  ];
  postFixup = ''
    wrapPythonProgramsIn $out/bin "$out $pythonPath"
    wrapProgram $out/bin/ebook2audiobook \
      --run "${ebook2audiobook-run}" \
      --prefix PATH : "${lib.makeBinPath [ calibre ffmpeg ]}"
  '';

  meta = {
    description = "Generate audiobooks from e-books, voice cloning & 1107+ languages";
    homepage = "https://github.com/DrewThomasson/ebook2audiobook";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ebook2audiobook";
  };
}
