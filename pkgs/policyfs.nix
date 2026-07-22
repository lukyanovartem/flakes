{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  fuse, makeWrapper
}:

buildGoModule (finalAttrs: {
  pname = "policyfs";
  version = "1.0.6";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "hieutdo";
    repo = "policyfs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0Eap8XllPqJ9hjfbe9Xzf6LLCIriqgmFAM3iBax8cV8=";
  };

  vendorHash = "sha256-BXN8x+6h6KYLCM5iJ70MWjSruJGwYy9ekPU3e+gCFUE=";

  ldflags = [ "-s" ];

  passthru.updateScript = nix-update-script { };

  doCheck = false;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    mkdir -p $out/lib/systemd/system
    for i in `ls ./packaging/systemd`; do
      substitute ./packaging/systemd/"$i" $out/lib/systemd/system/"$i" \
        --replace-warn /usr/bin/pfs $out/bin/pfs
    done
    wrapProgram $out/bin/pfs \
      --set PATH ${lib.makeBinPath [ fuse ]}
  '';

  meta = {
    description = "Linux FUSE storage daemon with routing rules and SQLite metadata index";
    homepage = "https://github.com/hieutdo/policyfs";
    changelog = "https://github.com/hieutdo/policyfs/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "policyfs";
  };
})
