[![Template](https://img.shields.io/badge/Template-lighblack/?color=gray&logo=github)](#)
[![iso-cpp](https://img.shields.io/badge/C++-blue.svg?style=flat&logo=c%2B%2B)](https://isocpp.org/)
[![Built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org/)
[![kotur.me](https://img.shields.io/badge/Author-kotur.me-blue?style=flat)](https://kotur.me)

# C++ & Nix project template

Starter project for your C++ application with Nix as a package manager  
If you don't know what the Nix package manager is, please look at the [FAQ](#faq) section

## About project

Configured to work when used both as a regular [nix derivation][doc-nix-derivation], and as a 
[flake][doc-nix-flake]. In both cases, the version of `nixpkgs` is used from `flake.lock` (JSON file). 
That way, we get some of the flake advantages even when using it as a regular derivation.

Similar to `nixpkgs`, project leverages the custom [`kotur-nixpkgs`](https://github.com/nkoturovic/kotur-nixpkgs) 
channel for all package requirements that are not available within `nixpkgs`. One such example is the python package
[`dinosay`](https://github.com/nkoturovic/kotur-nixpkgs/blob/master/pkgs/dinosay/default.nix), which is being used to display
the welcome message at the moment of entering the dev shell with `nix-shell` command.

## Project structure

- [`default.nix`][file-default.nix] - Definition for the package being defined by this repo, list of dependencies (nix packages)
- [`shell.nix`][file-shell.nix] - Uses `default.nix` to read shell definition and exposes it to the user
- [`flake.nix`][file-flake.nix] - Enables using the package as a flake
- [`flake.lock`][file-flake.lock] - Locked version of packages (mainly nixpkgs) which are used both for default flake use-case

## Commands

In this section, you can find various commands that can help you use the full potential of tools used within the project

### Build with Nix

- Building the package
  - `nix-build` - default way
  - `nix build` - flakes way

### Develop with Nix

- Enter the development environment (shell)
  - `nix-shell` - default way, use --pure to enter shell in pure mode
  - `nix develop` - flakes way, use -i to ignore the environment

### Other nix commands

- `nix flake update` - Updates `flake.lock` file (used both by `flake.nix` and `default.nix`)
- `nix fmt .` - Format nix files based on a formatter specified in the `flake.nix` file
- `nix run .#generate-compile-commands` - Force regenerate `compile_commands.json`

Flakes are still an experimental feature of Nix, to add flake support look at the [flakes documentation][doc-nix-flake]

### Building with [CMake][web-cmake] from dev shell

After entering the dev environment, you can use the standard [CMake][web-cmake] procedure to build the project. 

```sh
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)
```
  
## Exporting `compile_commands.json`

**NOTE**: Compile commands are **automatically generated** when entering the development shell (`nix-shell` or `nix develop`).

The setup detects if your build dependencies have changed and automatically updates the config for you.

### Manually regenerating `compile_commands.json`

If you ever need to manually trigger a regeneration (e.g. after a git pull), you can run:

```sh
# From inside the shell
generate-compile-commands --force

# Or from outside
nix run .#generate-compile-commands
```

## FAQ

List of frequently asked questions:

- [What is the Nix package manager?][doc-nix-manual]
- [How to install the Nix package manager?][web-nix-install]

[doc-nix-manual]: https://nixos.org/manual/nix/stable/
[web-nix-install]: https://nixos.org/download.html#download-nix
[doc-nix-derivation]: https://nixos.org/manual/nix/stable/language/derivations.html
[doc-nix-flake]: https://nixos.wiki/wiki/Flakes
[file-default.nix]: ./default.nix
[file-shell.nix]: ./shell.nix
[file-flake.nix]: ./flake.nix
[file-flake.lock]: ./flake.lock
[web-cmake]: https://cmake.org/
[web-kotur.me]: https://kotur.me
