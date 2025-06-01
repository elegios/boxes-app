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
    frontend = pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "boxes";
      version = "v1";
      src = ./frontend;

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
    backend = pkgs.buildGoModule {
      pname = "backend";
      version = "v1";
      src = ./backend;

      vendorHash = null;
    };
    wbackend = pkgs.runCommand "mkBackend" {buildInputs = [pkgs.makeWrapper];} ''
      mkdir -p $out/bin
      makeWrapper ${backend}/bin/boxes-app $out/bin/boxes-app \
        --add-flags "-s ${frontend}/lib/node_modules/boxes-app/dist"
    '';
  in {
    packages.x86_64-linux.frontend = frontend;
    packages.x86_64-linux.backend = backend;
    packages.x86_64-linux.wbackend = wbackend;
    devShells.x86_64-linux.default = pkgs.mkShell {
      name = "dev shell";
      buildInputs = [
        pkgs.svelte-language-server
        pkgs.gopls
      ];
      inputsFrom = [ frontend backend ];
    };
  };
}
