{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      # rclone sync file
      rclone

      # aws query like sql query
      steampipe

      # workflow simulation
      wrkflw

    ];
  };

}
