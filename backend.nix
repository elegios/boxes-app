{ buildGoModule }:

buildGoModule {
  pname = "backend";
  version = "v1";
  src = ./backend;

  vendorHash = null;

  meta.mainProgram = "boxes-app";
}
