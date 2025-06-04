{ stdenv, fetchYarnDeps, yarnConfigHook, yarnBuildHook, yarnInstallHook, nodejs }:

stdenv.mkDerivation (finalAttrs: {
  pname = "boxes";
  version = "v1";
  src = ./frontend;

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-N5guhlPO+tM+EsQpUgA0vLvTGNna1FqBGbE6bt1XJ4Q=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];
})
