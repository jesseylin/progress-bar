{
  description = "Static build of the progress-bar SvelteKit SPA.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.default = with pkgs;
        buildNpmPackage {
          pname = "progress-bar";
          version = "0.0.1";
          src = ./.;

          # Update with `nix build` then copy the suggested hash, or run
          # `prefetch-npm-deps package-lock.json`.
          npmDepsHash = "sha256-iNlZOwsNSAZq6eS2elUDQcxwIputcTzDiiHWnpX3llI=";

          # Subpath under which the SPA is mounted on jesseylin.com.
          BASE_PATH = "/progress-bar";

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r build/. $out/
            runHook postInstall
          '';
        };

      devShells.default = with pkgs;
        mkShell {
          packages = [nodejs];
        };
    });
}
