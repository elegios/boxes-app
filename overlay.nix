final: prev: {
  boxes-app = final.callPackage ./backend.nix {};
  boxes-app-frontend = final.callPackage ./frontend.nix {};
}
