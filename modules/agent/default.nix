{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      llm-agents.pi
      #unstable.pi-coding-agent

      # nono sandbox
      llm-agents.nono
    ];
  };
}
