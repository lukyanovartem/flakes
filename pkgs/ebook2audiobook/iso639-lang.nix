{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "iso639-lang";
  version = "2.6.3";
  pyproject = true;

  src = fetchPypi {
    pname = "iso639_lang";
    inherit version;
    hash = "sha256-B43bfNAYLcwENnaRrMgCLd9xWLbLCfCPeYr4I/qGQmU=";
  };

  build-system = [
    setuptools
  ];

  meta = {
    description = "A fast, comprehensive, ISO 639 library";
    homepage = "https://pypi.org/project/iso639-lang/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
