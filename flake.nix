{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            (pkgs.callPackage ./kargo.nix { })
          ] ++ (with pkgs; [
            awscli
            git
            glab
            jq
            kubectl
            kubelogin-oidc
            poetry
            pre-commit
            python312
            shellcheck
            terraform
            vault
            yq
          ]);
        };
    });
}
