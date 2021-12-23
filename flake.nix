{
  description = "A flake of MOTD files.";

  inputs.nixpkgs.url = github:NixOS/nixpkgs;
  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, flake-utils }:
    let
      motdFiles = {
        "40k" = ./40k-thought-for-the-day.txt;
        rebirth = ./boi-rebirth-fortunes.txt;
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        motd = pkgs.stdenv.mkDerivation {
          pname = "motd";
          version = "1.0";
          builder = builtins.toFile "motd-builder.sh" ''
            source $stdenv/setup
            mkdir -p $out
            ${builtins.foldl'
              (a: b: "${a}\n${b}")
              ""
              (map
                (attr: "cp ${motdFiles.${attr}} $out/${attr}.txt")
                (builtins.attrNames motdFiles))}
          '';
        };
      in
      {
        defaultPackage = motd;
      }
    );
}
