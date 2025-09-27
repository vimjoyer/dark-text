{
  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.symlinkJoin {
      name = "quickshell";
      paths = [pkgs.quickshell];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/quickshell --add-flags "-c ${./.}"
      '';
    };
  };
}
