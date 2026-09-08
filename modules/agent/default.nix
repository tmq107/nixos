{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      #llm-agents.opencode
      #llm-agents.pi
      unstable.pi-coding-agent

      #support tool for ai integration
      himalaya

      # nono sandbox
      unstable.nono
    ];
  };
}
