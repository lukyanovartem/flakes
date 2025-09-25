{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  SDL2, pkg-config, gtk3, requireFile, gnused, directx-shader-compiler, clangStdenv, makeWrapper, lld
}:

let
  rom = requireFile rec {
    name = "mm.n64.us.1.0.z64";
    sha256 = "0arzwhxmxgyy6w56dgm5idlchp8zs6ia3yf02i2n0qp379dkdcgg";
    message = ''
      $ sha1sum ${name}
      d6133ace5afaa0882cf214cf88daba39e266c078 ${name}
    '';
  };
  z64decompress = stdenv.mkDerivation rec {
    pname = "z64decompress";
    version = "unstable-2023-12-22";

    src = fetchFromGitHub {
      owner = "z64utils";
      repo = "z64decompress";
      rev = "e2b3707271994a2a1b3afc6c3997a7cf6b479765";
      hash = "sha256-PHiOeEB9njJPsl6ScdoDVwJXGqOdIIJCZRbIXSieBIY=";
    };

    installPhase = ''
      install -Dm755 z64decompress $out/bin/z64decompress
    '';

    meta = {
      description = "Zelda 64 rom decompressor";
      homepage = "https://github.com/z64utils/z64decompress";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ ];
      mainProgram = "z64decompress";
      platforms = lib.platforms.all;
    };
  };
  n64recomp = stdenv.mkDerivation rec {
    pname = "n64-recomp";
    version = "mod-tool-release";

    src = fetchFromGitHub {
      owner = "N64Recomp";
      repo = "N64Recomp";
      rev = version;
      hash = "sha256-t4MSbGAqeK1u40yVbIlLonmwo/CHTeMykfeonLWyuXE=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      cmake
    ];

    installPhase = ''
      install -Dm755 ./N64Recomp $out/bin/N64Recomp
      install -Dm755 ./RSPRecomp $out/bin/RSPRecomp
    '';

    meta = {
      description = "Tool to statically recompile N64 games into native executables";
      homepage = "https://github.com/N64Recomp/N64Recomp";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ ];
      platforms = lib.platforms.all;
    };
  };
  zelda64-recomp-run = ''
    config="''${XDG_CONFIG_HOME:-''$HOME/.config}"/Zelda64Recompiled
    if [[ ! -d "$config" ]]; then
      mkdir -p "$config"
    fi
    ln -sf ${rom} "$config"/mm.n64.us.1.0.z64
  '';
in clangStdenv.mkDerivation rec {
  pname = "zelda64-recomp";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "Zelda64Recomp";
    repo = "Zelda64Recomp";
    rev = "v${version}";
    hash = "sha256-lsGnxgQqQ8wFc/qSVRFYxF0COir+eeH/flf4ePo98WA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake pkg-config gnused makeWrapper lld
  ];

  buildInputs = [
    SDL2 gtk3
  ];
  preConfigure = ''
    sed -i 's#set (DXC "LD_LIBRARY_PATH=''${PROJECT_SOURCE_DIR}/lib/rt64/src/contrib/dxc/lib/x64" "''${PROJECT_SOURCE_DIR}/lib/rt64/src/contrib/dxc/bin/x64/dxc-linux")#set (DXC "${lib.getExe' directx-shader-compiler "dxc"}")#' CMakeLists.txt
    sed -i 's#set (DXC "LD_LIBRARY_PATH=''${PROJECT_SOURCE_DIR}/src/contrib/dxc/lib/x64" "''${PROJECT_SOURCE_DIR}/src/contrib/dxc/bin/x64/dxc-linux")#set (DXC "${lib.getExe' directx-shader-compiler "dxc"}")#' ./lib/rt64/CMakeLists.txt
    ${lib.getExe z64decompress} ${rom} mm.us.rev1.rom_uncompressed.z64
    ln -s ${lib.getExe' n64recomp "N64Recomp"}
    ln -s ${lib.getExe' n64recomp "RSPRecomp"}
    ./N64Recomp us.rev1.toml
    ./RSPRecomp aspMain.us.rev1.toml
    ./RSPRecomp njpgdspMain.us.rev1.toml
  '';

  hardeningDisable = [
    "zerocallusedregs" "pic" "stackprotector"
  ];

  installPhase = ''
    install -Dm755 ./Zelda64Recompiled $out/Zelda64Recompiled
    install -Dm644 $src/recompcontrollerdb.txt $out/recompcontrollerdb.txt
    cp -r $src/assets $out
    makeWrapper $out/Zelda64Recompiled $out/bin/Zelda64Recompiled \
      --run '${zelda64-recomp-run}' \
      --chdir "$out"
  '';

  meta = {
    description = "Static recompilation of Majora's Mask (and soon Ocarina of Time) for PC (Windows/Linux/Mac";
    homepage = "https://github.com/Zelda64Recomp/Zelda64Recomp";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "Zelda64Recompiled";
    platforms = lib.platforms.all;
  };
}
