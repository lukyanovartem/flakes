{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  einops,
  encodec,
  huggingface-hub,
  numpy,
  pyyaml,
  scipy,
  torch,
  torchaudio,
}:

buildPythonPackage rec {
  pname = "vocos";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gemelo-ai";
    repo = "vocos";
    rev = "v${version}";
    hash = "sha256-K1ontwueJm42j8m8lkn+Xto031dZ3D9mG6FeVyJeHDo=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    einops
    encodec
    huggingface-hub
    numpy
    pyyaml
    scipy
    torch
    torchaudio
  ];

  pythonImportsCheck = [
    "vocos"
  ];

  meta = {
    description = "Vocos: Closing the gap between time-domain and Fourier-based neural vocoders for high-quality audio synthesis";
    homepage = "https://github.com/gemelo-ai/vocos";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
