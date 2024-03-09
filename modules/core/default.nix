{ inputs, nixpkgs, self, ...}:
let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  lib = nixpkgs.lib;
in
{
  nixos = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit self inputs; };
    modules =
        [ 
        inputs.disko.nixosModules.default
        inputs.home-manager.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
        ]
        ++ [ (import ./configuration.nix) ]
        ++ [ (import ./disko.nix) ]
        ++ [ (import ./../../hosts/desk/hardware-configuration.nix) ]
    ;
  };
}