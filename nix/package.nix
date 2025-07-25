{
  git,
  lib,
  makeWrapper,
  nodejs_22,
  pnpm_10,
  stdenv,
  headplanePnpmHash ? "sha256-3aXY1kKbKhwYhuVpqBolR+iKRQTbtiF1SYg9OjcrqDk=",
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "headplane";
  version = (builtins.fromJSON (builtins.readFile ../package.json)).version;
  src = ../.;

  nativeBuildInputs = [
    makeWrapper
    nodejs_22
    pnpm_10.configHook
    git
  ];

  dontCheckForBrokenSymlinks = true;

  pnpmDeps = pnpm_10.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = headplanePnpmHash;
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/headplane}
    cp -r build $out/share/headplane/
    sed -i "s;$PWD;../..;" $out/share/headplane/build/server/index.js
    makeWrapper ${lib.getExe nodejs_22} $out/bin/headplane \
        --chdir $out/share/headplane \
        --add-flags $out/share/headplane/build/server/index.js
    runHook postInstall
  '';
})
