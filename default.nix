{
  system ? builtins.currentSystem,
  lock ? builtins.fromJSON (builtins.readFile ./flake.lock),
  # The official nixpkgs input, pinned with the hash defined in the flake.lock file
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
  # Helper tool for generating compile-commands.json
  miniCompileCommands ?
    fetchTarball {
      url = "https://github.com/danielbarter/mini_compile_commands/archive/${lock.nodes.miniCompileCommands.locked.rev}.tar.gz";
      sha256 = lock.nodes.miniCompileCommands.locked.narHash;
    },
  # Custom nixpkgs channel, owner's nickname is kotur, hence kotur-nixpkgs
  kotur-nixpkgs ? let
    koturPkgs = fetchTarball {
      url = "https://github.com/nkoturovic/kotur-nixpkgs/archive/${lock.nodes.koturNixPkgs.locked.rev}.tar.gz";
      sha256 = lock.nodes.koturNixPkgs.locked.narHash;
    };
  in
    import koturPkgs {
      inherit system;
    },
}: let
  # Stdenv is base for packaging software in Nix It is used to pull in dependencies such as the GCC toolchain,
  # GNU make, core utilities, patch and diff utilities, and so on. Basic tools needed to compile a huge pile
  # of software currently present in nixpkgs.
  # Some platforms have different toolchains in their StdEnv definition by default
  # To ensure gcc, we used gccStdenv as a base instead of just stdenv
  # mkDerivation is the main function used to build packages with the standard environment.
  package = pkgs.gcc12Stdenv.mkDerivation (self: {
    name = "cpp-nix-app";
    version = "0.0.3";

    # Programs and libraries used/available at build-time
    nativeBuildInputs = with pkgs; [
      gcc12Stdenv # Also used bellow with mini_compile_commands in shell
      ncurses
      cmake
      gnumake
    ];

    # Programs and libraries used by the new derivation at run-time
    buildInputs = with pkgs; [
      fmt
      kotur-nixpkgs.cpp-jwt
    ];

    # builtins.path is used since source of our package is the current directory: ./
    # Alternatively, you can use: fetchFromGitHub, fetchTarball or similar
    src = builtins.path {
      path = ./.;

      # Filter all files that begin with '.', for example '.git', that way
      # .git directory will not become part of the source of our package
      filter = path: type:
        !(pkgs.lib.hasPrefix "." (baseNameOf path));
    };

    # Nix is smart enough to :wq

    # Specify cmake flags
    # cmakeFlags = [ "-DMYAR=Foo" ];

    # buildDir = "build-nix-${self.name}-${self.version}";

    # configurePhase = ''
    #   mkdir ./${self.buildDir} && cd ./${self.buildDir}
    #   cmake .. -DCMAKE_BUILD_TYPE=Release
    # '';

    # buildPhase = ''
    #   make -j$(nproc)
    # '';

    # installPhase = ''
    #   mkdir -p $out/bin
    #   cp src/${self.name} $out/bin/
    # '';

    # passthru - it is meant for values that would be useful outside of the derivation
    # in other parts of a Nix expression (e.g. in other derivations)
    passthru = {
      # inherit has nothing to do with OOP, it's a nix-specific syntax for
      # inheriting (copying) variables from the surrounding lexical scope
      inherit pkgs shell;
      # equivalent to:
      # pkgs = pkgs
      # shell = shell
    };
  });

  # Using mini_compile_commands to export compile_commands.json
  # https://github.com/danielbarter/mini_compile_commands/
  # Look at the README.md file for instructions on generating compile_commands.json
  mcc-env = (pkgs.callPackage miniCompileCommands {}).wrap pkgs.gcc12Stdenv;

  # Development shell
  shell = (pkgs.mkShell.override {stdenv = mcc-env;}) {
    # Copy build inputs (dependencies) from the derivation the nix-shell environment
    # That way, there is no need for speciying dependenvies separately for derivation and shell
    inputsFrom = [
      package
    ];

    # Shell (dev environment) specific packages
    packages = with pkgs; [
      neovim
    ];

    # Hook used for modifying the prompt look and printing the welcome message
    shellHook = ''
      PS1="\[\e[32m\][\[\e[m\]\[\e[33m\]nix-shell\\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\\$\[\e[m\] "
      alias ll="ls -l"
      cowsay "Welcome to the '${package.name}' dev environment!" 2> /dev/null
    '';
  };
in
  package
