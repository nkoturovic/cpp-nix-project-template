{
  system ? builtins.currentSystem,
  lock ? builtins.fromJSON (builtins.readFile ./flake.lock),
  pkgs ? let
    nixpkgs = fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
      sha256 = lock.nodes.nixpkgs.locked.narHash;
    };
  in
    import nixpkgs {
      overlays = [];
      config = {};
      inherit system;
    },
  miniCompileCommands ?
    fetchTarball {
      url = "https://github.com/danielbarter/mini_compile_commands/archive/${lock.nodes.miniCompileCommands.locked.rev}.tar.gz";
      sha256 = lock.nodes.miniCompileCommands.locked.narHash;
    },
}: let
  package = pkgs.gcc12Stdenv.mkDerivation (self: {
    name = "cpp-nix-app";
    version = "0.0.3";

    nativeBuildInputs = with pkgs; [
      gcc12Stdenv # Also used bellow with mini_compile_commands in shell
      ncurses
      cmake
      gnumake
    ];

    buildInputs = with pkgs; [
      fmt
    ];

    src = builtins.path {
      path = ./.;
      filter = path: type:
        !(pkgs.lib.hasPrefix "." (baseNameOf path));
    };

    buildDir = "build-nix-${self.name}-${self.version}";

    configurePhase = ''
      mkdir ./${self.buildDir} && cd ./${self.buildDir}
      cmake .. -DCMAKE_BUILD_TYPE=Release
    '';

    buildPhase = ''
      make -j$(nproc)
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp src/${self.name} $out/bin/
    '';

    passthru = {
      inherit pkgs shell;
    };
  });

  # Shell specific parameters

  # Using mini_compile_commands to export compile_commands.json
  # https://github.com/danielbarter/mini_compile_commands/
  mcc-env = (pkgs.callPackage miniCompileCommands {}).wrap pkgs.gcc12Stdenv;

  # Development shell
  shell = (pkgs.mkShell.override {stdenv = mcc-env;}) {
    inputsFrom = [
      package
    ];

    packages = with pkgs; [
      neovim
    ];

    shellHook = ''
      PS1="\[\e[32m\][\[\e[m\]\[\e[33m\]nix-shell\\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\\$\[\e[m\] "
      alias ll="ls -l"
      echo "Welcome to the '${package.name}' dev environment!"
    '';
  };
in
  package
