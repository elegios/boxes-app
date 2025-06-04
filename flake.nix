{
  description = "Stuff";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
    frontend = pkgs.callPackage ./frontend.nix {};
    backend = pkgs.callPackage ./backend.nix {};
  in {
    nixosModules.default = ./module.nix;
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
