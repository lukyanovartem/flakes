{
  lib,
  stdenv,
  fetchgit,
  python3Packages, rsync, ffmpeg
}:

let
  fb2tts-run = ''
    ${lib.getExe rsync} -a ${placeholder "out"}/fb2tts/ ~/.config/TTS-Server
    chmod -R +w ~/.config/TTS-Server
    cd ~/.config/TTS-Server
  '';
in stdenv.mkDerivation rec {
  pname = "fb2tts";
  version = "unstable";

  src = fetchgit {
    url = "https://gitverse.ru/diger/fb2tts";
    rev = "ff3d095f17527c39e75ded15530decd266641767";
    hash = "sha256-55PDMpp4Lkrv9Ie+rHpq4nUFzMdEeb3T+z0664du5Vk=";
  };

  nativeBuildInputs = with python3Packages; [ python wrapPython ];

  buildPhase = ''
    substituteInPlace libs/tts/f5_backend/model/utils.py \
      --replace-fail "import rjieba" ""
    substituteInPlace app.py \
      --replace-fail "gr.Audio(interactive=False, buttons=[])" "gr.Audio(interactive=False)" \
      --replace-fail "theme=custom_theme," ""
    substituteInPlace gr_tabs/settings_tab.py \
      --replace-fail "gr.Audio(interactive=False, type='filepath', buttons=[])" "gr.Audio(interactive=False, type='filepath')"
    sed -i '1 i\#!/usr/bin/env python' app.py
    chmod +x app.py
    patchShebangs app.py
  '';

  installPhase = ''
    mkdir -p $out/fb2tts
    cp -r * $out/fb2tts
    mkdir -p $out/${python3Packages.python.sitePackages} $out/bin
    mv $out/fb2tts/libs $out/fb2tts/config.py $out/fb2tts/gr_tabs $out/${python3Packages.python.sitePackages}
    mv $out/fb2tts/app.py $out/bin/fb2tts
  '';

  pythonPath = with python3Packages; [
    gradio torch torchaudio librosa onnxruntime transformers razdel
    vocos x-transformers torchdiffeq lxml pymorphy3
  ];

  postFixup = ''
    wrapPythonProgramsIn $out/bin "$out $pythonPath"
    wrapProgram $out/bin/fb2tts \
      --run "${fb2tts-run}" \
      --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}"
  '';

  meta = {
    description = "";
    homepage = "https://gitverse.ru/diger/fb2tts";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "fb2tts";
    platforms = lib.platforms.all;
  };
}
