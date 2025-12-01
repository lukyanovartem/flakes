{
  lib,
  stdenv,
  fetchzip,
  cmake,
  pkg-config,
  alsa-lib,
  bluez,
  curl,
  ffmpeg,
  freetype,
  gettext,
  harfbuzz,
  icu,
  libgit2,
  poppler,
  pugixml,
  SDL2,
  libGL,
  fetchsvn,
  cctools,
  libtiff,
  libpng,
  zlib,
  libwebp,
  libraw,
  openexr_2,
  openjpeg,
  jxrlib,
  fetchFromGitHub,
  nasm,
  openjdk,
  enableJava ? false, # whether to build the java wrapper
  enableJpeg7 ? false, # whether to build libjpeg with v7 compatibility
  enableJpeg8 ? false, # whether to build libjpeg with v8 compatibility
  enableStatic ? stdenv.hostPlatform.isStatic,
  enableShared ? !stdenv.hostPlatform.isStatic,

  # for passthru.tests
  dvgrab,
  epeg,
  gd,
  graphicsmagick,
  imagemagick,
  imlib2,
  jhead,
  libjxl,
  mjpegtools,
  opencv,
  python3,
  vips,
  testers,
}:

let
  freeimage = 
stdenv.mkDerivation (finalAttrs: {
  pname = "freeimage";
  version = "3.18.0-unstable-2024-04-18";

  src = fetchsvn {
    url = "svn://svn.code.sf.net/p/freeimage/svn/";
    rev = "1911";
    hash = "sha256-JznVZUYAbsN4FplnuXxCd/ITBhH7bfGKWXep2A6mius=";
  };

  sourceRoot = "${finalAttrs.src.name}/FreeImage/trunk";

  # Ensure that the bundled libraries are not used at all
  prePatch = ''
    rm -rf Source/Lib* Source/OpenEXR Source/ZLib
  '';

  # Tell patch to work with trailing carriage returns
  patchFlags = [
    "-p1"
    "--binary"
  ];

  patches = [
    ./unbundle.diff
    ./CVE-2020-24292.patch
    ./CVE-2020-24293.patch
    ./CVE-2020-24295.patch
    ./CVE-2021-33367.patch
    ./CVE-2021-40263.patch
    ./CVE-2021-40266.patch
    ./CVE-2023-47995.patch
    ./CVE-2023-47997.patch
  ];

  postPatch = ''
    # To support cross compilation, use the correct `pkg-config`.
    substituteInPlace Makefile.fip \
      --replace "pkg-config" "$PKG_CONFIG"
    substituteInPlace Makefile.gnu \
      --replace "pkg-config" "$PKG_CONFIG"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libtiff
    libtiff.dev_private
    libpng
    zlib
    libwebp
    libraw
    openexr_2
    openjpeg
    libjpeg
    libjpeg.dev_private
    jxrlib
  ];

  postBuild = ''
    make -f Makefile.fip
  '';

  INCDIR = "${placeholder "out"}/include";
  INSTALLDIR = "${placeholder "out"}/lib";

  preInstall = ''
    mkdir -p $INCDIR $INSTALLDIR
  '';

  postInstall =
    ''
      make -f Makefile.fip install
    '';

  enableParallelBuilding = true;

  meta = {
    description = "Open Source library for accessing popular graphics image file formats";
    homepage = "http://freeimage.sourceforge.net/";
    license = "GPL";
    maintainers = with lib.maintainers; [ ];
    platforms = with lib.platforms; linux;
  };
});
libjpeg = stdenv.mkDerivation (finalAttrs: {

  pname = "libjpeg-turbo";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "libjpeg-turbo";
    repo = "libjpeg-turbo";
    rev = finalAttrs.version;
    hash = "sha256-ZNqhOfZtWcMv10VWIUxn7MSy4KhW/jBrgC1tUFKczqs=";
  };

  patches =
    [
      # This is needed by freeimage
      ./0001-Compile-transupp.c-as-part-of-the-library.patch
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isMinGW) [
      ./0002-Make-exported-symbols-in-transupp.c-weak.patch
    ]
    ++ lib.optionals stdenv.hostPlatform.isMinGW [
      ./mingw-boolean.patch
    ];

  outputs = [
    "bin"
    "dev"
    "dev_private"
    "out"
    "man"
    "doc"
  ];

  postFixup = ''
    moveToOutput include/transupp.h $dev_private
  '';

  nativeBuildInputs =
    [
      cmake
      nasm
    ]
    ++ lib.optionals enableJava [
      openjdk
    ];

  cmakeFlags =
    [
      "-DENABLE_STATIC=${if enableStatic then "1" else "0"}"
      "-DENABLE_SHARED=${if enableShared then "1" else "0"}"
    ]
    ++ lib.optionals enableJava [
      "-DWITH_JAVA=1"
    ]
    ++ lib.optionals enableJpeg7 [
      "-DWITH_JPEG7=1"
    ]
    ++ lib.optionals enableJpeg8 [
      "-DWITH_JPEG8=1"
    ]
    ++ lib.optionals stdenv.hostPlatform.isRiscV [
      # https://github.com/libjpeg-turbo/libjpeg-turbo/issues/428
      # https://github.com/libjpeg-turbo/libjpeg-turbo/commit/88bf1d16786c74f76f2e4f6ec2873d092f577c75
      "-DFLOATTEST=fp-contract"
    ];

  doInstallCheck = true;
  installCheckTarget = "test";

  passthru.tests = {
    inherit
      dvgrab
      epeg
      gd
      graphicsmagick
      imagemagick
      imlib2
      jhead
      libjxl
      mjpegtools
      opencv
      vips
      ;
    inherit (python3.pkgs) pillow imread pyturbojpeg;
    pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = with lib; {
    homepage = "https://libjpeg-turbo.org/";
    description = "Faster (using SIMD) libjpeg implementation";
    license = licenses.ijg; # and some parts under other BSD-style licenses
    pkgConfigModules = [
      "libjpeg"
      "libturbojpeg"
    ];
    maintainers = with maintainers; [
      vcunat
      kamadorueda
    ];
    platforms = platforms.all;
  };
});
in stdenv.mkDerivation (finalAttrs: {
  pname = "emulationstation-de";
  version = "3.4.0";

  src = fetchzip {
    url = "https://gitlab.com/es-de/emulationstation-de/-/archive/v${finalAttrs.version}/emulationstation-de-v${finalAttrs.version}.tar.gz";
    hash = "sha256-poegMKtPtUbdUbAwVj6O+rh7bxou+Wc+IDS3TBHh2LU=";
  };

  patches = [
    ./001-add-nixpkgs-retroarch-cores.patch
  ];

  postPatch = ''
    # ldd-based detection fails for cross builds
    substituteInPlace CMake/Packages/FindPoppler.cmake \
      --replace-fail 'GET_PREREQUISITES("''${POPPLER_LIBRARY}" POPPLER_PREREQS 1 0 "" "")' ""
  '';

  nativeBuildInputs = [
    cmake
    gettext # msgfmt
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    bluez
    curl
    ffmpeg
    freeimage
    freetype
    harfbuzz
    icu
    libgit2
    poppler
    pugixml
    SDL2
    libGL
  ];

  cmakeFlags = [ (lib.cmakeBool "APPLICATION_UPDATER" false) ];

  meta = {
    description = "ES-DE (EmulationStation Desktop Edition) is a frontend for browsing and launching games from your multi-platform collection";
    homepage = "https://es-de.org";
    maintainers = with lib.maintainers; [ ivarmedi ];
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "es-de";
  };
})