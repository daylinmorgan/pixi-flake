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
  ...
}:

rustPlatform.buildRustPackage rec {
  pname = "pixi";
  version = "0.36.0";

  src = fetchFromGitHub {
    owner = "prefix-dev";
    repo = "pixi";
    rev = "v${version}";
    hash = "sha256-xPEnOxysUHUIa2C3MqAeeaYgAf5TQQytq2LxyzWYaMQ=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "async_zip-0.0.17" = "sha256-3k9rc4yHWhqsCUJ17K55F8aQoCKdVamrWAn6IDWo3Ss=";
      "pubgrub-0.2.1" = "sha256-8TrOQ6fYJrYgFNuqiqnGztnHOqFIEDi2MFZEBA+oks4=";
      "reqwest-middleware-0.3.3" = "sha256-KjyXB65a7SAfwmxokH2PQFFcJc6io0xuIBQ/yZELJzM=";
      "tl-0.7.8" = "sha256-F06zVeSZA4adT6AzLzz1i9uxpI1b8P1h+05fFfjm3GQ=";
      "uv-auth-0.0.1" = "sha256-xy/fgy3+YvSdfq5ngPVbAmRpYyJH27Cft5QxBwFQumU=";
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
