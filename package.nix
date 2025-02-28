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
  version = "0.42.0";

  src = fetchFromGitHub {
    owner = "prefix-dev";
    repo = "pixi";
    rev = "v${version}";
    hash = "sha256-IT+USqTJW8HOfnY6TvW0cGFpDEd1/N46C+a0bQi88Ss=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-0+b+OjefaPMzplw/S8jEB8uc9n2NXNrUBKcgzxzAhnc=";

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
