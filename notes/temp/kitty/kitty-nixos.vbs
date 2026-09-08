Set shell = CreateObject("WScript.Shell")
shell.Run "wsl.exe -d NixOS --cd ~ /home/quanthai/.local/bin/kitty-wsl", 0, False

