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
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "prefix-dev";
    repo = "pixi";
    rev = "v${version}";
    hash = "sha256-4evZ1xdxbAVzjs1Rb580lCN4tuW+FZF7Vnro2PSKqT8=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "async_zip-0.0.17" = "sha256-3k9rc4yHWhqsCUJ17K55F8aQoCKdVamrWAn6IDWo3Ss=";
      "cache-key-0.0.1" = "sha256-3FSA+JsAbLzS3ONoLciDzpyCsO6Em8lNVYR43WiK1xs=";
      "pubgrub-0.2.1" = "sha256-yhZm35Dyl6gcBTxKvsxJXv1GTOuMCDknnSTgGgKD488=";
      "reqwest-middleware-0.3.2" = "sha256-OiC8Kg+F2eKy7YNuLtgYPi95DrbxLvsIKrKEeyuzQTo=";
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
