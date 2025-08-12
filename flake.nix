{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=55d1f923c480dadce40f5231feb472e81b0bab48";
    nur = {
      url = "github:nix-community/NUR?rev=ad500bcca20e1749278e396b70dc682f8807ac21";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, ... }@attrs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
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
