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

  home.packages = let
    patchedDiscord = (pkgs.discord.override {
    withOpenASAR = true;
    withVencord = true;
    });
  in
  [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them
    # misc
    pkgs.cowsay
    pkgs.catppuccin-kde
    pkgs.rclone
    pkgs.deezer-enhanced
    pkgs.kdePackages.kolourpaint
    patchedDiscord
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

programs.obs-studio = {
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
    settings = {
      general = {
      # Umbriel's built-in systemd synchronization makes only one attempt. Retry
      # it so a user-manager startup race cannot leave the session without Noctalia.
      autostart = [
        ''
          until systemctl --user import-environment WAYLAND_DISPLAY DISPLAY \
            XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE UMBRIEL_SOCKET \
            && systemctl --user start umbriel-session.target
          do
            sleep 1
          done
        ''
      ];
      mod_key = "Super";
      xwayland = true;
      show_cheatsheet = true;
      focus_on_activate = false;
    };

    environment = {
      NIXOS_OZONE_WL = "1";
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = "24";
      TERMINAL = "kitty";
    };

    output.DP-2 = {
    mode = "2560x1440@164.83";
    position = [0 0];
    scale = 1;
    focus_at_startup = true;
    vrr = false;
    hdr = false;
    };

    workspaces.back_and_forth = true;

    appearance = {
      prefer_no_csd = true;
      border_width = 1;
      outer_border_width = 0;
      corner_radius = 8;
      drag_opacity = 0.9;
      blur.enabled = false;
      shadow.enabled = false;
    };

    input = {
      middle_click_paste = true;
      keyboard.layout = "";
      touchpad = {
        tap = true;
        natural_scroll = true;
        disable_while_typing = true;
      };
      mouse.sensitivity = 0.0;
      cursor = {
        theme = "Adwaita";
        size = 24;
        follows_focus = false;
        hide_when_typing = false;
      };
      focus.follows_mouse = true;
    };

    layout = {
      mode = "dwindle";
      gap = 4;
      extent_presets = [
        0.333
        0.5
        0.667
        1.0
      ];
      dwindle.preserve_split = true;
    };

    keybinds = {
      "Mod+T" = "spawn kitty";
      "Mod+B" = "spawn floorp";
      "Mod+E" = "spawn dolphin";
      "Mod+R" = "spawn noctalia msg panel-toggle launcher";
      "Mod+Space" = "spawn noctalia msg panel-toggle launcher";
      "Mod+P" = "spawn noctalia msg panel-toggle launcher";
      "Mod+V" = "spawn noctalia msg panel-toggle clipboard";
      "Mod+Shift+V" = "spawn noctalia msg clipboard-clear";
      "Mod+N" = "spawn noctalia msg notification-invoke-latest";
      "Mod+Shift+N" = "spawn noctalia msg notification-dnd-toggle";
      "Mod+Shift+R" = "config-reload";
      "Mod+Shift+L" = "spawn noctalia msg session lock";
      "Mod+Shift+H" = {
        action = "cheatsheet-toggle";
        repeat = false;
      };
      "Mod+Escape" = "spawn noctalia msg panel-toggle session";

      "Mod+Q" = "window-close";
      "Mod+Shift+F" = "spawn umbriel msg window-toggle-floating && umbriel msg window-center";
      "Mod+Shift+G" = "window-toggle-fullscreen";
      "Mod+Shift+M" = "window-toggle-maximize";
      "Mod+Shift+P" = "window-toggle-pinned";

      "Mod+Left" = "window-focus-left";
      "Mod+Right" = "window-focus-right";
      "Mod+Up" = "window-focus-up";
      "Mod+Down" = "window-focus-down";
      "Mod+H" = "window-focus-left";
      "Mod+J" = "window-focus-down";
      "Mod+K" = "window-focus-up";
      "Mod+L" = "window-focus-right";

      "Mod+Ctrl+H" = "window-modify-primary-extent:-0.1";
      "Mod+Ctrl+J" = "window-modify-secondary-extent:0.1";
      "Mod+Ctrl+K" = "window-modify-secondary-extent:-0.1";
      "Mod+Ctrl+L" = "window-modify-primary-extent:0.1";
      "Mod+Alt+H" = "column-move-left";
      "Mod+Alt+J" = "window-move-down";
      "Mod+Alt+K" = "window-move-up";
      "Mod+Alt+L" = "column-move-right";

      "Mod+S" = "scratchpad-toggle";
      "Mod+Shift+S" = "window-move-to-scratchpad";
      "Mod+WheelUp" = {
        action = "workspace-previous";
        cooldown_ms = 150;
      };
      "Mod+WheelDown" = {
        action = "workspace-next";
        cooldown_ms = 150;
      };

      "Print" = {
        action = "spawn noctalia msg screenshot-region";
        repeat = false;
      };
      "Shift+Print" = {
        action = "spawn noctalia msg screenshot-fullscreen";
        repeat = false;
      };

      "XF86AudioRaiseVolume" = {
        action = "spawn noctalia msg volume-up";
        allow_when_locked = true;
      };
      "XF86AudioLowerVolume" = {
        action = "spawn noctalia msg volume-down";
        allow_when_locked = true;
      };
      "XF86AudioMute" = {
        action = "spawn noctalia msg volume-mute-toggle";
        allow_when_locked = true;
      };
      "XF86AudioMicMute" = {
        action = "spawn noctalia msg microphone-mute-toggle";
        allow_when_locked = true;
      };
      "XF86MonBrightnessUp" = {
        action = "spawn noctalia msg brightness-up 5";
        allow_when_locked = true;
      };
      "XF86MonBrightnessDown" = {
        action = "spawn noctalia msg brightness-down 5";
        allow_when_locked = true;
      };
      "XF86AudioNext" = {
        action = "spawn noctalia msg media next";
        allow_when_locked = true;
      };
      "XF86AudioPause" = {
        action = "spawn noctalia msg media toggle";
        allow_when_locked = true;
      };
      "XF86AudioPlay" = {
        action = "spawn noctalia msg media toggle";
        allow_when_locked = true;
      };
      "XF86AudioPrev" = {
        action = "spawn noctalia msg media previous";
        allow_when_locked = true;
      };
    };

    window_rule = [
      {
        match.is_focused = false;
        opacity = 0.97;
      }
      {
        match.app_id = "^dev[.]noctalia[.]Noctalia$";
        default_floating = true;
        default_floating_size_px = {
          width = 1020;
          height = 900;
        };
      }
      {
        match.app_id = "^dev[.]noctalia[.]UmbrielSharePicker$";
        default_floating = true;
        default_floating_size_px = {
          width = 800;
          height = 600;
        };
      }
      {
        match.app_id = "^(org[.]gnome[.]Calculator|org[.]gnome[.]Nautilus|org[.]pulseaudio[.]pavucontrol|pavucontrol|nm-connection-editor|org[.]gnome[.]Settings|xdg-desktop-portal.*)$";
        default_floating = true;
      }
      {
        match.title = "^(Picture-in-Picture|Picture in picture)$";
        default_floating = true;
        default_position = {
          x = 20;
          y = 20;
          anchor = "bottom_right";
        };
      }
    ];

    animation = {
      enabled = true;
      duration_ms = 200;
      curve = "easeout";
      windows_in = {
        enabled = true;
        duration_ms = 150;
        style = "popin";
        scale = 0.9;
      };
      windows_out = {
        enabled = true;
        duration_ms = 150;
        style = "fade";
      };
      windows_move.enabled = true;
      workspaces.enabled = true;
      overview.enabled = true;
      scratchpad = {
        enabled = true;
        dim = 0.3;
        blur = false;
      };
    };
#       };
     };
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
