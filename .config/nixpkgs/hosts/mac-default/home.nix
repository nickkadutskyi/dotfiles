{ config, pkgs, ... }:
{
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Development
    devenv # development environment
    go # Probably for gcloud
    dart-sass # for sass to css conversion

    # PHP Develpoment
    php83 # PHP 8.3 (currently latest) to run symfony console completion
    php83Packages.composer # package manager for PHP (to init PHP projects)
    symfony-cli # for Symfony dev

    # JavaScript Development
    pnpm # package manager for JavaScript
    nodePackages_latest.nodejs
    # dart # disabled due to conflict with composer

    # Lua Development
    lua54Packages.lua # For lua development and neovim configs
    lua54Packages.luarocks # lua package manager
    stylua # lua formatter

    # Tools
    awscli2 # AWS CLI
    google-cloud-sdk # Google Cloud SDK
    ffmpeg # for video conversion
    dos2unix # convert text files with different line breaks
    imagemagick # for image conversion
    pandoc # for markdown conversion

    # Nix
    nixfmt-classic # format nix files
    nixpkgs-fmt # format nixpkgs files
    nil # nix lsp server

    # Misc
    exercism # for coding exercises

    # Zsh
    zsh-completions # don't why I need this?
    zsh-powerlevel10k # prompt style
    zsh-autosuggestions # autosuggests with grey text from history
    zsh-syntax-highlighting # highglits binaries in terminal

    # Fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) # Configures main font

  ] ++ (pkgs.lib.optionals (pkgs.lib.strings.hasInfix "linux" system)
    [
      git
    ]
  ) ++ (pkgs.lib.optionals (pkgs.lib.strings.hasInfix "darwin" system)
    [
      blueutil # control bluetooth (probably use in some script)
      duti # set default applications for document types and URL schemes
      perl # updating built-in perl 
    ]
  );

  fonts.fontconfig.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  home.file =
    let
      gitIgnoreGlobal = import ./home-files/gitignore_global.nix { inherit pkgs; };
    in
    {
      ".gitconfig" = {
        enable = true;
        executable = false;
        source = import ./home-files/gitconfig.nix {
          inherit pkgs;
          gitignore = gitIgnoreGlobal;
        };
      };
    };

  programs.zsh =
    let
      # is embedded into zshenv and zprofile for different kinds of shells
      zpath = /* bash */ ''
        # Homebrew
        HOMEBREW_PREFIX=$([ -d "/opt/homebrew" ] && echo /opt/homebrew || echo /usr/local)
        # Set PATH, MANPATH, etc., for Homebrew.
        [ -d $HOMEBREW_PREFIX ] && eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
        #zpath User's private binaries and scripts
        export PATH="$PATH:$HOME/bin"
        # Tizen CLI
        export PATH=/Users/nick/Tizen/tizen-studio/tools/ide/bin:$PATH
        # Rust related
        [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
        # Composer vendor binaries
        export PATH="$HOME/.composer/vendor/bin:$PATH"
      '';
    in
    {
      enable = true;
      enableCompletion = true;
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = ./p10k-config;
          file = "p10k.zsh";
        }
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.zsh-syntax-highlighting;
          file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        }
        {
          name = "zsh-completions";
          src = pkgs.zsh-completions;
          file = "share/zsh-completions/zsh-completions.plugin.zsh";
        }
      ];
      history = {
        save = 1000000000;
        size = 1000000000;
        ignoreAllDups = false;
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "git-extras" ];
      };
      initExtraFirst = /* bash */ ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      initExtraBeforeCompInit = /* bash */ ''

    '';
      initExtra = /* bash */ ''
        HISTSIZE=1000000

        # INIT
        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        # [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        # Fuzzy search
        [ -x "$(command -v fzf)" ] && eval "$(fzf --zsh)"

        # FUNCTIONS
        # Fuzzy search functions
        # fd - cd to selected directory
        fd() {
          local dir
          dir=''$(find ''${1:-.} -path '*/\.*' -prune \
                          -o -type d -print 2> /dev/null | fzf +m) &&
          cd "''$dir"
        }
        # fh - search in your command history and execute selected command
        fh() {
          eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
        }

        # pnpm
        export PNPM_HOME="/Users/nick/Library/pnpm"
        case ":$PATH:" in
          *":$PNPM_HOME:"*) ;;
          *) export PATH="$PNPM_HOME:$PATH" ;;
        esac
        # pnpm end

      '';
      envExtra = /* bash */ ''
        # Configure paths before loading the shell
        if [[ $SHLVL == 1 && ! -o LOGIN ]]; then
          ${zpath}
        fi

        # Default editor
        export EDITOR=nvim
        export VISUAL="$EDITOR"
        # GPG
        GPG_TTY=$(tty)
        export GPG_TTY
        # Lang settings
        export LC_ALL=en_US.UTF-8
        export LANG=en_US.UTF-8
      '';
      profileExtra = /* bash */ ''
        if [[ $SHLVL == 1 ]]; then
          ${zpath}
        fi
      '';
      shellAliases = {
        sc = "symfony console";
        sym = "symfony";
        mfs = /* bash */ "php artisan migrate:fresh --seed";
        mfss = /* bash */ "mfs && php artisan db:seed --class=DevSeeder";
        ip = /* bash */ "curl -4 icanhazip.com";
        ip4 = /* bash */ "curl -4 icanhazip.com";
        ip6 = /* bash */ "curl -6 icanhazip.com";
        iplan = /* bash */ "ifconfig en0 inet | grep 'inet ' | awk ' { print \$2 } '";
        ips = /* bash */ "ifconfig -a | perl -nle'/(\\d+\\.\\d+\\.\\d+\\.\\d+)/ && print \$1'";
        ip4a = /* bash */ "dig +short -4 myip.opendns.com @resolver4.opendns.com";
        ip6a = /* bash */ "dig +short -6 myip.opendns.com @resolver1.ipv6-sandbox.opendns.com AAAA";
        vi = "nvim";
        vim = "nvim";
        view = "nvim -R";
        vimdiff = "nvim -d";
        # EPDS
        # List EPDS AWS EC2 Instances
        epds_ec2 = "aws ec2 describe-instances  --query 'Reservations[].Instances[?not_null(Tags[?Key==\`Name\`].Value)]|[].[State.Name,PrivateIpAddress,PublicIpAddress,InstanceId,Tags[?Key==\`Name\`].Value[]|[0]] | sort_by(@, &[3])'  --output text |  sed '$!N;s/ / /'";
      };
    };

  # programs.zsh.oh-my-zsh.enable = true;

  targets.darwin.defaults = {
    "com.apple.dock" = {
      autohide = true;
    };

    NSGlobalDomain = {
      # Instead of specia char menu repeat the character
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      # Appearance to auto
      AppleInterfaceStyleSwitchesAutomatically = true;
      # Languages in Regional Settings
      AppleLanguages = [
        "en-US"
        "ru-US"
        "uk-US"
      ];
      AppleLocale = "en_US";
      # "com.apple.mouse.tapBehavior" = 1;
      # Delay before starting key repeat
      InitialKeyRepeat = 15;
      # Frequency of key repeat
      KeyRepeat = 2;
    };

    "com.apple.AppleMultitouchTrackpad" = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    "com.apple.WindowManager" = {
      GloballyEnabled = true;
      EnableStandardClickToShowDesktop = 0;
      StandardHideDesktopIcons = 0;
      HideDesktop = 1;
      StageManagerHideWidgets = 0;
      StandardHideWidgets = 1;
      AutoHide = true;
      EnableTiledWindowMargins = 0;
    };

    "com.apple.Safari" = {
      IncludeDevelopMenu = true;
      AutoFillCreditCardData = false;
      AutoFillPasswords = false;
      AutoFillMiscellaneousForms = false;
      AutoOpenSafeDownloads = true;
      ShowOverlayStatusBar = true;
      "ShowFavoritesBar-v2" = false;
      AlwaysRestoreSessionAtLaunch = true;
      HomePage = "";
      ShowStandaloneTabBar = false;
      EnableNarrowTabs = true;
      SuppressSearchSuggestions = false;
      CommandClickMakesTabs = true;
      OpenNewTabsInFront = false;
      UniversalSearchEnabled = true;
      SendDoNotTrackHTTPHeader = true;
      WebKitStorageBlockingPolicy = 1;
      PreloadTopHit = true;
      ExtensionsEnabled = true;
      FindOnPageMatchesWordStartsOnly = false;
    };

    "com.apple.finder" = {
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    # Keyboard Shortucts
    "com.apple.symbolichotkeys" = {
      # Option + 1/2/3 to switch between Desktops
      AppleSymbolicHotKeys = {
        "118" = {
          enabled = true;
          value = {
            parameters = [ 49 18 524288 ];
            type = "standard";
          };
        };
        "119" = {
          enabled = true;
          value = {
            parameters = [ 50 19 524288 ];
            type = "standard";
          };
        };
        "120" = {
          enabled = true;
          value = {
            parameters = [ 51 20 524288 ];
            type = "standard";
          };
        };
      };
    };

  };
}
