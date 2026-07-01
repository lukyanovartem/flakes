{
  lib,
  stdenv,
  fetchurl,
  nix-update-script,
  zip, snapraid
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snapraid-daemon";
  version = "1.12";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "https://github.com/amadvance/snapraid-daemon/releases/download/v${finalAttrs.version}/snapraid-daemon-${finalAttrs.version}.tar.gz";
    hash = "sha256-o8csC67Y0eloAgabuE3TtyNUa+oIUld9dJ0NQo1vUoU=";
  };

  nativeBuildInputs = [ zip ];

  preConfigure = ''
    substituteInPlace Makefile.in \
      --replace-fail "\$(sysconfdir)/snapraidd.conf" "$out/etc/snapraidd.conf"
    substituteInPlace daemon/unix.c \
      --replace-fail "/usr/bin/snapraid" "${lib.getExe snapraid}"
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--with-init-type=systemd"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A lightweight daemon for SnapRAID featuring a REST API, job scheduler, and web interface";
    homepage = "https://github.com/amadvance/snapraid-daemon";
    changelog = "https://github.com/amadvance/snapraid-daemon/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [
      bsd2
      gpl3Only
      mit
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "snapraid-daemon";
    platforms = lib.platforms.all;
  };
})
