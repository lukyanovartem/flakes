{
  lib,
  python3Packages,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  gdk-pixbuf,
  gobject-introspection,
  hicolor-icon-theme,
  desktop-file-utils, fetchFromGitHub
}:

python3Packages.buildPythonApplication {
  pname = "nirimod";
  version = "unstable-2026-05-30";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "srinivasr";
    repo = "nirimod";
    rev = "f86518f7b2cd13b08591122bd49e770100808313";
    hash = "sha256-k9LEaef54u+P2yJXLQP+GtRSXQRSXKEBmszkze7tOfg=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
    desktop-file-utils
  ];

  build-system = with python3Packages; [
    hatchling
  ];

  buildInputs = [
    gtk4
    libadwaita
    gdk-pixbuf
    hicolor-icon-theme
  ];

  dependencies = with python3Packages; [
    pygobject3
  ];

  postInstall = ''
    install -Dm644 data/nirimod.svg $out/share/icons/hicolor/scalable/apps/nirimod.svg

    mkdir -p $out/share/applications
    cat > $out/share/applications/io.github.nirimod.desktop << EOF
    [Desktop Entry]
    Version=1.0
    Name=NiriMod
    GenericName=Compositor Settings
    Comment=GUI Configuration Manager for the Niri Wayland Compositor
    Exec=nirimod
    Icon=nirimod
    Terminal=false
    Type=Application
    Categories=Utility;Settings;DesktopSettings;
    Keywords=compositor;windowmanager;wayland;niri;settings;config;
    StartupNotify=true
    StartupWMClass=nirimod
    EOF
  '';

  meta = {
    description = "A polished GTK4/libadwaita GUI configurator for the niri Wayland compositor";
    homepage = "https://github.com/srinivasr/nirimod";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "nirimod";
    platforms = lib.platforms.linux;
  };
}
