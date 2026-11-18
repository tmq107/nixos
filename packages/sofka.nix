{
  lib,
  stdenvNoCC,
  fetchurl,
  gnutar,
  gzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "sofka";
  version = "0.37.0";

  src = fetchurl {
    url = "https://github.com/nklmilojevic/sofka/releases/download/v${version}/sofka-v${version}-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-APwc4cMUQZf1we36VewPzlOkZ5KAYi733WO7CNzCxKM=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [
    gnutar
    gzip
  ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 sofka $out/bin/sofka
    runHook postInstall
  '';

  meta = {
    description = "A Kubernetes TUI, reimagined in Rust";
    homepage = "https://github.com/nklmilojevic/sofka";
    mainProgram = "sofka";
    platforms = [ "x86_64-linux" ];
    license = with lib.licenses; [
      mit
      asl20
    ];
  };
}
