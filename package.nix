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
  version = "0.41.0";

  src = fetchFromGitHub {
    owner = "prefix-dev";
    repo = "pixi";
    rev = "v${version}";
    hash = "sha256-QZHDH2UZmDC4u6TdS0mPzlJG5fdugXOXZG3eq2DupoA=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "async_zip-0.0.17" = "sha256-VfQg2ZY5F2cFoYQZrtf2DHj0lWgivZtFaFJKZ4oyYdo=";
      "pubgrub-0.2.1" = "sha256-zusQxYdoNnriUn8JCk5TAW/nQG7fwxksz0GBKEgEHKc=";
      "tl-0.7.8" = "sha256-F06zVeSZA4adT6AzLzz1i9uxpI1b8P1h+05fFfjm3GQ=";
      "uv-auth-0.0.1" = "sha256-iiIbSya+SUM7Xk+lV7h7Zyb1WMvc1IAHxCAylWmKaKU=";
    };
  };

  # The following packages are duplicated which is not supported by buildRustPackage:
  # - version-ranges
  #
  # postPatch = ''
  #   cp ${./Cargo.lock} Cargo.lock
  # '';

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
