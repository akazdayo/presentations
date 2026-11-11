{buildNpmPackage}:
buildNpmPackage {
  pname = "prettier-plugin-slidev";
  version = "1.0.5";
  src = ./.;
  npmDepsHash = "sha256-H3BeLagpZKxaYiQow5hJavaIQIUK1DpQ1CEW44Os6V0=";
  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r node_modules "$out/"
    runHook postInstall
  '';
}
