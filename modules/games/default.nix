{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      mgba
      azahar
    ];
  };
}
