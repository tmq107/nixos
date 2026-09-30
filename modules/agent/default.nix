{ pkgs, ... }:

{
  users.users.quanthai = {
    packages = with pkgs; [
      llm-agents.pi

      # nono sandbox
      llm-agents.nono

      # terminal for AI
      llm-agents.herdr
    ];
  };
}
