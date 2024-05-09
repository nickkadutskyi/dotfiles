{ pkgs, inputs, ... }:
{
  environment.userLaunchAgents.snippety-helper = {
    enable = true;
    source = ./snippety-agent.plist;
    target = "org.nixos.snippety-helper.plist";
  };
}
