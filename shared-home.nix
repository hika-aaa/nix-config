{ inputs, config, pkgs, lib, ... }:

{
  # Import files from the current configuration directory into the Nix store,
  # and create symbolic links pointing to those store files in the Home directory.

  imports = [ inputs.umbriel.homeModules.default ];

  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # Import the scripts directory into the Nix store,
  # and recursively generate symbolic links in the Home directory pointing to the files in the store.
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  #xresources.properties = {
  #  "Xcursor.size" = 16;
  #  "Xft.dpi" = 172;
  #};

  # Packages that should be installed to the user profile.
  home.packages = [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them
    # misc
    pkgs.cowsay
    pkgs.catppuccin-kde
    pkgs.rclone
    pkgs.deezer-enhanced
    pkgs.kdePackages.kolourpaint
    #productivity
    pkgs.zotero
    pkgs.super-productivity
    pkgs.anki
    #games
    pkgs.itch
    pkgs.heroic
    inputs.grimoire.packages.${pkgs.system}.default
    #privacy
    pkgs.tor-browser
    pkgs.signal-desktop
    pkgs.mullvad-browser
  ];


  # basic configuration of git, please change to your own
  programs = {
    git = {
        enable = true;
        package = pkgs.gitFull;
        settings = {
          init.defaultBranch = "main";
          safe.directory = "/etc/nixos";
          user = {
            name = "hika";
            email = "hikadani@gmail.com";
          };
          alias = {
          ci = "commit";
          co = "checkout";
          s = "status";
          sync = "!git pull --rebase && git push";
          push = { autoSetupRemote = true; };
          };
        };
    };
    obsidian.enable = true;
    kitty = {
        enable = true;
        #themeFile = "Catppuccin-Macchiato";
    };
  };

programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;

  shellAliases = {
    #ll = "ls -l";
    #edit = "sudo -e";
    update = "sudo nixos-rebuild switch";
    nix-search="nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
  };

  history.size = 10000;
  history.ignoreAllDups = true;
  history.path = "$HOME/.zsh_history";
  history.ignorePatterns = ["rm *" "pkill *" "cp *"];

   antidote = {
    enable = true;
    plugins = [''
      zsh-users/zsh-autosuggestions
    '']; # explanation of "path:..." and other options explained in Antidote README.
    };
};

programs.hyfetch = {
  enable = true;
  settings = {
    color_align = {
      mode = "vertical";
    };
    mode = "rgb";
    preset = "lesbian";
    backend = "neofetch";
    pride_month_disable = false;
  };
};

services.nextcloud-client = {
  enable = true;
  startInBackground = true;
};

programs.keepassxc.enable = true;

programs.prismlauncher = {
  enable = true;
};


# Noctalia
programs.noctalia = {
  enable = true;

  #settings = { # This may also be a string or path to a .toml file.
    #theme = {
      #mode = "dark";
      #source = "builtin";
      #builtin = "Catppuccin";
    #};
  #};
};


# Umbriel

programs.umbriel = {
    enable = true;
#     settings = {
#       general.autostart = [ "noctalia" ];
#       layout.gap = 5;
#       input.keyboard.layout = "de";
#       keybinds = {
#         "Mod+T" = "spawn kitty";
#         "Mod+Q" = "window-close";
#         "Mod" = "spawn noctalia msg panel-toggle launcher";
#       };
#     };
  };


# systemd.user.services.rclone-gdrive-mount = {
#   Unit = {
#     Description = "Service that connects to Google Drive";
#     #After = [ "network-online.target" ];
#     #Requires = [ "network-online.target" ];
#   };
#   Install = {
#     WantedBy = [ "default.target" ];
#   };
#
#   Service = let
#     gdriveDir = "/run/media/hika/D/gdrive";
#     in
#     {
#       Type = "simple";
#       ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${gdriveDir}";
#       ExecStart = "${pkgs.rclone}/bin/rclone mount --vfs-cache-mode full gdrive: ${gdriveDir}";
#       ExecStop = "/run/current-system/sw/bin/fusermount -u ${gdriveDir}";
#       Restart = "on-failure";
#       RestartSec = "10s";
#       Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
#       #User=hika;
#       #Group=hika;
#     };
#   };

programs.vscode = {
  enable = true;
  package = pkgs.vscode.fhs;
};

#xdg.autostart = {
#  enable = true;
#  entries = [
#
#  ];
#};

# programs.anki = {
#   enable = true;
#   package = pkgs.anki;
#   profiles.hika = {
#   sync.username = "hikadani@gmail.com";
#   sync.keyFile = "/etc/nixos/keyfiles/ankikey.txt";
#   };
# };

# xdg.configFile."rclone/example.conf".text = ''
#   [drive]
#   type = drive
#   user = foo@bar.com
#   pass = p4ssw0rd
# '';
# };

# systemd.user.services.example-mounts = {
#   Unit = {
#     Description = "Example programmatic mount configuration with nix and home-manager.";
#     After = [ "network-online.target" ];
#   };
#   Service = {
#     Type = "notify";
#     ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Example Sync Dir";
#     ExecStart = "${pkgs.rclone}/bin/rclone --config=%h/.config/rclone/example.conf --vfs-cache-mode writes --ignore-checksum mount \"fichier:\" \"%h/Example Sync Dir\"";
#     ExecStop="/run/wrappers/bin/fusermount -u %h/Example Sync Dir/%i";
#   };
#   Install.WantedBy = [ "default.target" ];
# };

#   # starship - an customizable prompt for any shell
#   programs.starship = {
#     enable = true;
#     # custom settings
#     settings = {
#       add_newline = false;
#       aws.disabled = true;
#       gcloud.disabled = true;
#       line_break.disabled = true;
#     };
#   };

#   # alacritty - a cross-platform, GPU-accelerated terminal emulator
#   programs.alacritty = {
#     enable = true;
#     # custom settings
#     settings = {
#       env.TERM = "xterm-256color";
#       font = {
#         size = 12;
#         draw_bold_text_with_bright_colors = true;
#       };
#       scrolling.multiplier = 5;
#       selection.save_to_clipboard = true;
#     };
#   };

#   programs.bash = {
#     enable = true;
#     enableCompletion = true;
#     # TODO add your custom bashrc here
#     bashrcExtra = ''
#       export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
#     '';
#
#     # set some aliases, feel free to add more or remove some
#     shellAliases = {
#       k = "kubectl";
#       urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
#       urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
#     };
#   };

  # On rebuild, trigger KDE refresh
#   home.activation = {
#   myActivationAction = lib.hm.dag.entryAfter ["writeBoundary"] ''
#     rm ~/.cache/ksycoca6_* -rf && kbuildsycoca6
#   '';
#     };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  #home.stateVersion = "26.05";
}
