{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      # aws query like sql query
      steampipe

      # Rust
      rustc
      cargo

      # Zig
      zig
      zls
    ];
  };

}
