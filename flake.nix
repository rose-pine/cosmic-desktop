{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rose-pine-build = {
      url = "github:juliamertz/rose-pine-build?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { nixpkgs, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem =
        {
          pkgs,
          lib,
          system,
          ...
        }:
        let
          rose-pine-build = inputs.rose-pine-build.packages.${system}.binary;
        in
        {
          packages.default = pkgs.runCommandNoCC "generated" { } ''
            ${lib.getExe rose-pine-build} ${./templates} --tera -o $out
          '';

          devShells.default = pkgs.mkShell {
            packages = [
              rose-pine-build
            ];
          };
        };
    };
}
