{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.miniCompileCommands = {
    url = github:danielbarter/mini_compile_commands/v0.4;
    flake = false;
  };
  inputs.koturNixPkgs = {
    url = github:nkoturovic/kotur-nixpkgs/v0.3;
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
