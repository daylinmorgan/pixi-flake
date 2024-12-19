{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libgit2,
  openssl,
  installShellFiles,
  testers,
  pixi,
  ...
}:

rustPlatform.buildRustPackage rec {
  pname = "pixi";
  version = "0.39.3";

  src = fetchFromGitHub {
    owner = "prefix-dev";
    repo = "pixi";
    rev = "v${version}";
    hash = "sha256-QDnPXE6YY3AGUFtd6JRQVBAllO+acBBZ2yX+uNcBT7c=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "async_zip-0.0.17" = "sha256-VfQg2ZY5F2cFoYQZrtf2DHj0lWgivZtFaFJKZ4oyYdo=";
      "pubgrub-0.2.1" = "sha256-zusQxYdoNnriUn8JCk5TAW/nQG7fwxksz0GBKEgEHKc=";
      "tl-0.7.8" = "sha256-F06zVeSZA4adT6AzLzz1i9uxpI1b8P1h+05fFfjm3GQ=";
      "uv-auth-0.0.1" = "sha256-0tbaZ7xopQM0+nyLPiAH2zpS7rbWaIcT+f273ujbcQY=";
    };
  };

  # The following packages are duplicated which is not supported by buildRustPackage:
  # - version-ranges

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    libgit2
    openssl
  ];

  env = {
    LIBGIT2_NO_VENDOR = 1;
    OPENSSL_NO_VENDOR = 1;
  };

  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd pixi \
      --bash <($out/bin/pixi completion --shell bash) \
      --fish <($out/bin/pixi completion --shell fish) \
      --zsh <($out/bin/pixi completion --shell zsh)
  '';

  passthru.tests.version = testers.testVersion { package = pixi; };

  meta = with lib; {
    description = "Package management made easy";
    homepage = "https://pixi.sh/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ daylinmorgan ];
    mainProgram = "pixi";
  };
}
