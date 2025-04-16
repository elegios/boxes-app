{
  description = "Stuff";

  inputs = {
    # dream2nix.url = "github:nix-community/dream2nix";
    # nixpkgs.follows = "dream2nix/nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    # dream2nix,
    nixpkgs,
  }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
    pkg = pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "boxes";
      version = "v1";
      src = ./.;

      yarnOfflineCache = pkgs.fetchYarnDeps {
        yarnLock = finalAttrs.src + "/yarn.lock";
        hash = "sha256-N5guhlPO+tM+EsQpUgA0vLvTGNna1FqBGbE6bt1XJ4Q=";
      };

      nativeBuildInputs = [
        pkgs.yarnConfigHook
        pkgs.yarnBuildHook
        pkgs.yarnInstallHook
        pkgs.nodejs
      ];
    });
  in {
    packages.x86_64-linux.default = pkg;
    devShells.x86_64-linux.default = pkgs.mkShell {
      name = "dev shell";
      buildInputs = [
        pkgs.yarn
        pkgs.svelte-language-server
      ];
      inputsFrom = [ pkg ];
    };
  };
}
