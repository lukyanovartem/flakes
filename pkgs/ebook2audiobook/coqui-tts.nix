{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  anyascii,
  cython,
  einops,
  encodec,
  fsspec,
  gruut,
  inflect,
  librosa,
  matplotlib,
  monotonic-alignment-search,
  num2words,
  numba,
  numpy,
  packaging,
  pysbd,
  pyyaml,
  scipy,
  soundfile,
  torch,
  torchaudio,
  tqdm,
  transformers,
  typing-extensions,
  coqui-tts,
  bangla,
  bnnumerizer,
  bnunicodenormalizer,
  fugashi,
  g2pkk,
  jamo,
  pip,
  bokeh,
  pandas,
  umap-learn,
  flask,
  jieba,
  pypinyin,
  trainer
}:

buildPythonPackage rec {
  pname = "coqui-tts";
  version = "0.27.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "idiap";
    repo = "coqui-ai-TTS";
    rev = "v${version}";
    hash = "sha256-CPge6RJOM1CyW4bjjmNiCjOmxktcvcBgM9EDdjQTk7A=";
  };

  postPatch =
    let
      relaxedConstraints = [
        "bnunicodenormalizer"
        "coqpit-config"
        "cython"
        "gruut"
        "inflect"
        "librosa"
        "mecab-python3"
        "numba"
        "numpy"
        "unidic-lite"
        "trainer"
        "spacy\\[ja\\]"
        "transformers"
        "torch"
        "torchaudio"
      ];
    in
    ''
      sed -r -i \
        ${lib.concatStringsSep "\n" (
          map (package: ''-e 's/${package}\s*[<>=]+[^"]+/${package}/g' \'') relaxedConstraints
        )}
      pyproject.toml
    '';

  build-system = [
    hatchling
  ];

  dependencies = [
    anyascii
    cython
    einops
    encodec
    fsspec
    gruut
    inflect
    librosa
    matplotlib
    monotonic-alignment-search
    num2words
    numba
    numpy
    packaging
    pysbd
    pyyaml
    scipy
    soundfile
    torch
    torchaudio
    tqdm
    transformers
    typing-extensions
    trainer
  ];

  meta = {
    description = "A deep learning toolkit for Text-to-Speech, battle-tested in research and production";
    homepage = "https://github.com/idiap/coqui-ai-TTS";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
  };
}
