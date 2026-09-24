{
  description = "top down shooting game made with usagi engine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        pname = "crowgame";
        version = "0.0.1";
        src = ./.;
      in
      {
        devShells.default = pkgs.mkShellNoCC (finalArgs: {
          inherit pname version src;
          nativeBuildInputs = with pkgs; [
            # TODO: usagi
            stylua
            lua-language-server
            lua5_5
          ];
        });
      }
    );
}
