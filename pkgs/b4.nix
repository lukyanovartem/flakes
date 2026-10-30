{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule, nodejs, pnpmConfigHook, fetchPnpmDeps, pnpm
}:

let
  version = "1.39.1";
  src = fetchFromGitHub {
    owner = "DanielLavrushin";
    repo = "b4";
    rev = "v${version}";
    hash = "sha256-shO5qe58t56bIV9VK9XxE1Sfaf6MA30TJYdhrwI9QBQ=";
  };
  ui = stdenv.mkDerivation rec {
    pname = "b4-ui";
    inherit src version;

    setSourceRoot = ''export sourceRoot="$(echo */src/http/ui)"'';

    VITE_APP_VERSION = version;

    pnpmDeps = fetchPnpmDeps {
      inherit pname version src setSourceRoot;
      fetcherVersion = 3;
      hash = "sha256-hLtIkjXaL5ey7t8+WQPut8/Cp2HNCBOd4a1xdCG2tO8=";
    };

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    buildPhase = ''
      pnpm install && pnpm build
      mkdir $out
      cp -r dist $out
    '';
  };
in buildGoModule rec {
  pname = "b4";

  inherit version src;

  setSourceRoot = ''export sourceRoot="$(echo */src)"'';

  vendorHash = "sha256-QRnRq+HuzIiuWOqVZFzaA4GP9Lrs+jhptm+y/YRxd10=";

  preBuild = ''
    cp -r ${ui}/dist http/ui/
  '';

  doCheck = false;

  ldflags = [ "-X main.Version=${version}" "-X github.com/daniellavrushin/b4/http/handler.Version=${version}" ];

  meta = {
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "b4";
    platforms = lib.platforms.all;
  };
}
