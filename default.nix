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
  # Using mini_compile_commands to export compile_commands.json
  # https://github.com/danielbarter/mini_compile_commands/
  # Look at the README.md file for instructions on generating compile_commands.json
  mcc-env = (pkgs.callPackage miniCompileCommands {}).wrap pkgs.stdenv;
  mcc-hook = (pkgs.callPackage miniCompileCommands {}).hook;

  # Stdenv is base for packaging software in Nix It is used to pull in dependencies such as the GCC toolchain,
  # GNU make, core utilities, patch and diff utilities, and so on. Basic tools needed to compile a huge pile
  # of software currently present in nixpkgs.
  #
  # Some platforms have different toolchains in their StdEnv definition by default
  # To ensure gcc being default, we use gccStdenv as a base instead of just stdenv
  # mkDerivation is the main function used to build packages with the Stdenv
  package = mcc-env.mkDerivation (self: {
    name = "cpp-nix-app";
    version = "0.0.3";

    # Programs and libraries used/available at build-time
    nativeBuildInputs = with pkgs; [
      mcc-hook # hook for generating compile commands when building the package

      ncurses
      cmake
      gnumake
    ];

    # Programs and libraries used by the new derivation at run-time
    buildInputs = with pkgs; [
      fmt
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

    # Specify cmake flags
    cmakeFlags = [
      "--no-warn-unused-cli" # Supresses unused varibles warning
      # "-DMyVar=foo" # Example CMake argument
    ];

    # Nix is smart enough to detect we're using cmake to build our project
    # It will read our CMakeLists.txt file and create needed definitions
    # Alternatively, we could have been pre-defining the default phases that nix does
    # for a CMake based projects (see definitions bellow that are commented-out ###)

    ### buildDir = "build-nix-${self.name}-${self.version}";

    ### configurePhase = ''
    ###   mkdir ./${self.buildDir} && cd ./${self.buildDir}
    ###   cmake .. -DCMAKE_BUILD_TYPE=Release
    ### '';

    ### buildPhase = ''
    ###   make -j$(nproc)
    ### '';

    ### installPhase = ''
    ###   mkdir -p $out/bin
    ###   cp src/${self.name} $out/bin/
    ### '';

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

  # Development shell
  shell = (pkgs.mkShell.override {stdenv = mcc-env;}) {
    # Copy build inputs (dependencies) from the derivation the nix-shell environment
    # That way, there is no need for speciying dependenvies separately for derivation and shell
    inputsFrom = [
      package
    ];

    # Shell (dev environment) specific packages
    packages = with pkgs; [
      kotur-nixpkgs.dinosay # packet loads from the custom nixpkgs (kotur-nixpkgs)
    ];

    # Hook used for modifying the prompt look and printing the welcome message
    shellHook = ''
      PS1="\[\e[32m\][\[\e[m\]\[\e[33m\]nix-shell\\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[32m\]]\[\e[m\]\\$\[\e[m\] "
      alias ll="ls -l"
      dinosay -r -b happy -w 60 "Welcome to the '${package.name}' dev environment!"
    '';
  };
in
  package
