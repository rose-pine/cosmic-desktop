{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rosepine-build = {
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
          rosePineBuild = inputs.rosepine-build.packages.${system}.default;
        in
        {
          packages.default = pkgs.runCommandNoCC "generated" ''
            "${lib.getExe rosePineBuild} ${./templates} --tera -o $out"
          '';

          devShells.default = pkgs.mkShell {
            packages = [
              rosePineBuild
            ];
          };
        };
    };
}
