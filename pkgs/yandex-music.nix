{
  lib,
  stdenv,
  fetchurl, dpkg, makeWrapper, electron
}:

stdenv.mkDerivation rec {
  pname = "yandex-music";
  version = "5.101.2";

  src = fetchurl {
    url = "https://desktop.app.music.yandex.net/stable/Yandex_Music_amd64_${version}.deb";
    hash = "sha256-oAKzQfSQMRkbSlf+Vm6TY4W4mTLKU+hT1yQXpux2Dq4=";
  };


  nativeBuildInputs = [
    dpkg makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/opt/yandexmusic
    mv usr/share $out
    rm -r $out/share/doc

    mv opt/"Яндекс Музыка" opt/yandexmusic

    cp -r opt/yandexmusic/{locales,resources{,.pak}} "$out/opt/yandexmusic"

    makeWrapper ${electron}/bin/electron $out/bin/yandexmusic \
      --add-flags $out/opt/yandexmusic/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    substituteInPlace $out/share/applications/yandexmusic.desktop \
      --replace "/opt/Яндекс Музыка/" "$out/bin/" \
      --replace "Categories=Audio;" "Categories=AudioVideo;Audio;"
  '';

  meta = {
    description = "Linux client for Yandex Music";
    homepage = "https://music.yandex.ru/download/";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "yandexmusic";
    platforms = lib.platforms.all;
  };
}
