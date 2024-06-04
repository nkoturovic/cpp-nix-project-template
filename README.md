[![Template](https://img.shields.io/badge/Template-lighblack/?color=gray&logo=github)](#)
[![iso-cpp](https://img.shields.io/badge/C++-blue.svg?style=flat&logo=c%2B%2B)](https://isocpp.org/)
[![Built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org/)
[![kotur.me](https://img.shields.io/badge/Author-kotur.me-blue?style=flat)](https://kotur.me)

# C++ & Nix project template

Starter project for your C++ application with nix as a package manager  
If you don't know what nix package manager is, please look at the [FAQ](#faq) section

## About project

Configured to work when used both as a regular [nix derivation][doc-nix-derivation], and as a 
[flake][doc-nix-flake]. In both cases, the version of `nixpkgs` is used from `flake.lock` (JSON file). 
That way, we get some of the flake advantages even when using it as a regular derivation.

Similar to `nixpkgs`, project leverages the custom [`kotur-nixpkgs`](https://github.com/nkoturovic/kotur-nixpkgs) 
channel for all package requirements that are not available within `nixpkgs`. One such example is the python package
[`dinosay`](https://github.com/nkoturovic/kotur-nixpkgs/blob/master/pkgs/dinosay/default.nix), which is being used to display
the welcome message at the moment of entering dev shell with `nix-shell` command.

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
- `nix fmt` - Format nix files based on a formatter specified in `flake.nix` file

Flakes are still an experimental feature of Nix, to add flake support look at the [flakes documentation][doc-nix-flake]

### Building with [CMake][web-cmake] from dev shell

After entering the dev environment, you can use the standard [CMake][web-cmake] procedure to build the project. 

```sh
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)
```
  
## Exporting `compile_commands.json`

**NOTE**: Compile commands are automatically generated with `nix build`, or `nix-build`.

### Interactively export `compile_commands.json` from nix shell

In order to have autocompletion for the project, you can leverage `compile_commands.json` which can be exported by
following the steps described bellow

1. Open two terminal/shell instances and `cd` into the project
2. In both terminals enter the development shell (look how in [Nix commands section](#nix-commands))
3. In terminal one type

   ```sh
   mini_compile_commands_server.py
   ```

4. In terminal two use the [standard CMake build procedure](#building-with-cmake-from-dev-shell)
without the final (gnu) make command
5. In terminal one, terminate the app with `SIGINT` by pressing `Ctrl+c`
6. `compile_commands.json` file should be generated at the root of the project
7. Close terminal one, continue using or close terminal two

## FAQ

List of frequiently asked questions:

- [What is a nix package manager?][doc-nix-manual]
- [How to install the nix package manager?][web-nix-install]

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
