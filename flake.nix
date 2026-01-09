{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.koturNixPkgs = {
    url = github:nkoturovic/kotur-nixpkgs/v0.8.0;
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

      # wrapper script to run the generation command inside the dev environment
      generateCompileCommands = pkgs.writeShellScriptBin "generate-compile-commands" ''
        echo "Requesting compile_commands.json generation..."
        export NIX_SILENT=1 # Silence the welcome message during the command generation
        nix develop --command generate-compile-commands --force
      '';
    in {
      packages.default = package;
      devShells.default = package.shell;

      # Define the 'generate-compile-commands' app
      # Usage: nix run .#generate-compile-commands
      apps."generate-compile-commands" = {
        type = "app";
        program = "${generateCompileCommands}/bin/generate-compile-commands";
      };

      formatter = pkgs.alejandra;
    });
}
