{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      # Go
      go

      # NPM
      unstable.bun
      nodejs
      typescript

      # Python
      uv

      # Linting
      yamlfmt

      # Postman terminal
      posting

      # github folder download
      ghgrab
    ];
  };
}
