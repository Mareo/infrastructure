{ lib, buildGo123Module, fetchFromGitHub, installShellFiles }:

buildGo123Module rec {
  pname = "kargo";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "akuity";
    repo = "kargo";
    rev = "v${version}";
    sha256 = "sha256-mdyDB1ZnJ6XZUcPaLsp1Ugc2CmQY+AAAL1YjO1/oAI8=";
  };

  proxyVendor = true; # darwin/linux hash mismatch
  vendorHash = "sha256-KefqNXbcb8E5D+UmCuYGs22GC89GmKHU149yLee8fFg=";

  # Set target as ./cmd/cli per build-cli
  # https://github.com/akuity/kargo/blob/main/Makefile#L146
  subPackages = [ "cmd/cli" ];

  ldflags =
    let package_url = "github.com/akuity/kargo/internal/version"; in
    [
      "-s" "-w"
      "-X ${package_url}.version=${version}"
      "-X ${package_url}.gitCommit=${src.rev}"
      "-X ${package_url}.gitTag=${src.rev}"
      "-X ${package_url}.gitTreeState=clean"
    ];

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    export HOME=$(pwd)
    mkdir -p $out/bin
    install -Dm755 "$GOPATH/bin/cli" -T $out/bin/kargo
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/kargo version --client | grep ${version} > /dev/null
  '';

  postInstall = ''
    installShellCompletion --cmd kargo \
      --bash <($out/bin/kargo completion bash) \
      --zsh <($out/bin/kargo completion zsh)
  '';

  meta = with lib; {
    description = "Continuous delivery and application lifecycle orchestration platform for Kubernetes.";
    mainProgram = "kargo";
    downloadPage = "https://github.com/akuity/kargo";
    homepage = "https://kargo.io/";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
