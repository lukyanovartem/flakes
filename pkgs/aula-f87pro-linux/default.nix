{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  cairo,
  gdk-pixbuf,
  glib,
  gtk4,
  pango,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aula-f87pro-linux";
  version = "0.3.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "meursault03";
    repo = "aula-f87pro-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0QsPVwyS9nQqxrw5TdQ9/pzaMPepXsU34CG45MavJPw=";
  };

  cargoHash = "sha256-xrwBBCKQfAjZJCAnueSey9a7pc85qRzOQypvqmm2tCA=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    pango
  ];

  passthru.updateScript = nix-update-script { };

  buildFeatures = [
    "gui"
  ];

  patches = [ ./keys.patch ];

  meta = {
    description = "Native Linux app for configuring AULA F87 Pro keyboards: lighting, key remapping, USB macros and local profiles. Built with Rust and GTK4";
    homepage = "https://github.com/meursault03/aula-f87pro-linux";
    changelog = "https://github.com/meursault03/aula-f87pro-linux/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "aula-f87pro-linux";
  };
})
