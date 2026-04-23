{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "aula-keybind";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "vndarkblue";
    repo = "aula-keybind";
    rev = "v${version}";
    hash = "sha256-cnDH6vIWKpYOrzZpIVjvPS+VzPSbyYIaPAQMOS9OPmM=";
  };

  preBuild = ''
    substituteInPlace src/aula_keybind/outputs.py \
      --replace-fail "\"volume_down\": 0xEA," "\"volume_down\": 0xEA, \"brightness_down\": 0x70, \"brightness_up\": 0x6F,"
  '';

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    hidapi
  ];

  optional-dependencies = with python3.pkgs; {
    dev = [
      pyinstaller
      pytest
      pytest-cov
    ];
  };

  pythonImportsCheck = [
    "aula_keybind"
  ];

  meta = {
    description = "Remap Fn-layer and F13–F24 keys on AULA F87/F75 keyboards via USB HID. Persistent, no background app";
    homepage = "https://github.com/vndarkblue/aula-keybind";
    changelog = "https://github.com/vndarkblue/aula-keybind/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "aula-keybind";
  };
}
