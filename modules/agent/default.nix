{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      llm-agents.pi
      #unstable.pi-coding-agent

      #support tool for ai integration
      himalaya

      # nono sandbox
      llm-agents.nono
    ];
  };
}
