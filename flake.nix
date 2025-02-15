{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rose-pine-build = {
      url = "github:juliamertz/rosepine-buildrs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem =
        {
          config,
          pkgs,
          lib,
          system,
          ...
        }:
        let
          rose-pine-build = inputs.rose-pine-build.packages.${system}.default;
        in
        {
          packages.default = pkgs.runCommandNoCC "generated" {} ''
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
