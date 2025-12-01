{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=d542db745310b6929708d9abea513f3ff19b1341";
    nur = {
      url = "github:nix-community/NUR?rev=ad500bcca20e1749278e396b70dc682f8807ac21";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, ... }@attrs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    wrapWine = attrs.nur.legacyPackages.${system}.repos.lucasew.packages.wrapWine;
    localPkgs = import ./default.nix { inherit pkgs wrapWine; };
  in {
    packages.${system} = localPkgs;
    nixosModules = import ./modules // {
      default = { nixpkgs.overlays = [ (final: prev: { lukyanovartem = localPkgs; }) ]; };
    };
    overlays.default = import ./overlays;
  };
}
