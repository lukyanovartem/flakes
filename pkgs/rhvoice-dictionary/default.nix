{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages, rhvoice, installShellFiles
}:

stdenv.mkDerivation rec {
  pname = "rhvoice-dictionary";
  version = "unstable-2025-12-08";

  src = fetchFromGitHub {
    owner = "vantu5z";
    repo = "RHVoice-dictionary";
    rev = "40f3fb87cb84b1c67b48f4d5a1bcc9d8304b374a";
    hash = "sha256-QKG+6chCzwRJc2fvT41oW3hihW0WJZ5wIlDYwuA9R34=";
  };

  nativeBuildInputs = with python3Packages; [ python wrapPython installShellFiles ];

  buildPhase = ''
    cd tools
    substituteInPlace build.py \
      --replace-fail "getsitepackages()[0]" "\"lib\""
    substituteInPlace __init__.py \
      --replace-fail "from .rhvoice_say.rhvoice_say import rhvoice_say, say_clipboard" "" \
      --replace-fail "from .rhvoice_config.rhvoice_conf_gui import main as rhvoice_config" ""
    patchShebangs .
    ./build.py
    cd ..
  '';

  installPhase = ''
    mkdir -p $out/share/RHVoice $out/${python3Packages.python.sitePackages}
    cp -r dicts $out/share/RHVoice
    mv tools/build/lib/rhvoice_tools $out/${python3Packages.python.sitePackages}
    makeWrapper ${lib.getExe rhvoice} $out/bin/RHVoice-test \
      --set RHVOICE_CONFIG_PATH $out/share/RHVoice
    installBin ${./text-prepare}
  '';

  pythonPath = with python3Packages; [ pymorphy3 ];
  postFixup = ''
    wrapPythonProgramsIn $out/bin "$out $pythonPath"
  '';

  meta = {
    description = "Русский словарь для RHVoice и дополнительные инструменты";
    homepage = "https://github.com/vantu5z/RHVoice-dictionary";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
