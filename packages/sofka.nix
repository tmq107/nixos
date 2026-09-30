{ lib, stdenvNoCC, fetchurl, gnutar, gzip }:

stdenvNoCC.mkDerivation rec {
  pname = "sofka";
  version = "0.29.6";

  src = fetchurl {
    url = "https://github.com/nklmilojevic/sofka/releases/download/v${version}/sofka-v${version}-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-sd5y2ZdhIqx3jFkDjqY8SBngVQkmIJ3j1+N1/VauWI0=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ gnutar gzip ];
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
    license = with lib.licenses; [ mit asl20 ];
  };
}
