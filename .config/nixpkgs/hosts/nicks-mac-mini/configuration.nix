{ pkgs, inputs, ... }:
{
  homebrew = {
    casks = [
      # "paragon-ntfs" # brew only provides v16 and no v15 so install manually
      "steam"
      # "vmware-fusion" # 
      "crossover"
    ];
  };
}
