{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.miniCompileCommands = {
    url = github:danielbarter/mini_compile_commands/v0.6;
    flake = false;
  };
  inputs.koturNixPkgs = {
    url = github:nkoturovic/kotur-nixpkgs/v0.7.0;
    flake = false;
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      package = import ./default.nix {inherit system pkgs;};
    in {
      packages.default = package;
      devShells.default = package.shell;
      formatter = pkgs.alejandra;
    });
}
