{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libgit2,
  openssl,
  installShellFiles,
  darwin,
  testers,
  pixi,
  pixi-source,
  ...
}:

rustPlatform.buildRustPackage rec {
  pname = "pixi";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "prefix-dev";
    repo = "pixi";
    rev = "v${version}";
    hash = "sha256-m1qlDxZBEDUMNV+gRX2bbEdvBRp4lJv7C2ZZlEUA5Dg=";
  };

  cargoLock = {
    lockFile = "${pixi-source}/Cargo.lock";
    outputHashes = {
      "async_zip-0.0.17" = "sha256-Q5fMDJrQtob54CTII3+SXHeozy5S5s3iLOzntevdGOs=";
      "cache-key-0.0.1" = "sha256-tg3zRakZsnf7xBjs5tSlkmhkhHp5HGs6dwrTmdZBTl4=";
      "pubgrub-0.2.1" = "sha256-6tr+HATYSn1A1uVJwmz40S4yLDOJlX8vEokOOtdFG0M=";
    };

  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs =
    [
      libgit2
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin (
      with darwin.apple_sdk_11_0.frameworks;
      [
        CoreFoundation
        IOKit
        SystemConfiguration
        Security
      ]
    );

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
