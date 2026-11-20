# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, pkgs, lib, ... }:
let
  skwd-wall = inputs.skwd-wall.programs.${pkgs.stdenv.hostPlatform.system}.default;
  skwd-paper-plasma = inputs.skwd-wall.programs.${pkgs.stdenv.hostPlatform.system}.skwd-paper-plasma;
in
{
  imports =
    [ # Include the results of the hardware scan.
      #./hardware-configuration.nix
      #inputs.umbriel.nixosModules.default
    ];

  nix.package = pkgs.lixPackageSets.stable.lix;

  #programs.umbriel.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #bluetooth
  hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  };

  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    autoEnable = true;
    enable = true;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.backupCommand = pkgs.writeShellScript "kiotrash" ''
    ${pkgs.kdePackages.kde-cli-tools}/bin/kioclient move $1 trash:/
  '';

  home-manager.users.hika = {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "floorp.desktop";
      "x-scheme-handler/http" = "floorp.desktop";
      "x-scheme-handler/https" = "floorp.desktop";
      "x-scheme-handler/about" = "floorp.desktop";
      "x-scheme-handler/unknown" = "floorp.desktop";
    };
  };
};

  #home-manager.backupFileExtension = "bak";

  nixpkgs.overlays = [ inputs.millennium.overlays.default ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
    services.displayManager = {
    sddm.enable = true;
	autoLogin.enable = false;
	autoLogin.user = "hika";
	defaultSession = "plasma";
	sessionPackages = [ pkgs.umbriel ] ;
	};

  services.desktopManager.plasma6.enable = true;

  security = {
    # If enabled, pam_wallet will attempt to automatically unlock the user’s default KDE wallet upon login.
    # If the user has no wallet named “kdewallet”, or the login password does not match their wallet password,
    # KDE will prompt separately after login.
    pam = {
      services = {
        hika = {
          kwallet = {
            enable = true;
            package = pkgs.kdePackages.kwallet-pam;
          };
        };
      };
    };
};

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "se";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # Enable screensharing via xdg-desktop-portal
  xdg.portal = {
  enable = true;
  # Add the portal for your compositor, e.g.:
  extraPortals = with pkgs; [
    # xdg-desktop-portal-wlr # For Sway/wlroots
    # xdg-desktop-portal-gtk # For GNOME
    kdePackages.xdg-desktop-portal-kde # For KDE
  ];
};

  # Enable polkit
  security.polkit.enable = true;

  # Enable flakes!
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."hika" = {
    isNormalUser = true;
    description = "hika";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      floorp-bin
      equibop
      obsidian
    #  thunderbird
    ];
  };

  # Install "system" applications
  programs.firefox.enable = true;
  services.udisks2.enable = true;
  #programs.gnome-disks.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    package = pkgs.millennium-steam;
    extest.enable = true;
  };

   programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 10;
      };
      custom = {
        start = "notify-send -a 'Gamemode' 'Optimizations activated'";
        end = "notify-send -a 'Gamemode' 'Optimizations deactivated'";
      };
    };
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
  "firefox-esr-140-bin-unwrapped-140.17.0esr"
  ]; # allow because zotero needs it

  #Nixpkgs overlays
  #nixpkgs.overlays = [ inputs.grimoire.overlays.default ];


  services.flatpak.enable = true;
  services.jotta-cli.enable = true;

#   services.tor = {
#   enable = true;
#
#   # Disable GeoIP to prevent the Tor client from estimating the locations of Tor nodes it connects to
#   enableGeoIP = false;
#
#   # Enable Torsocks for transparent proxying of applications through Tor
#   torsocks.enable = true;
#
#   # Enable the Tor client
#   client = {
#     enable = true;
#   };
#   };


  #services.nextcloud = {
  #  enable = true;
  #  home = "/run/media/hika/D/Nextcloud";
  #  hostName = "https://drive.shadow.tech";
  #};

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
environment.systemPackages = let
    myPythonPackages = ps: with ps; [
      pandas
      statsmodels
      scikit-learn
      sympy
    ];
    myRPackages = with pkgs.rPackages; [
      reticulate # wanted by quarto to execute Python when using R.
      tidyverse
      languageserver
      # any other RPackages - you can reuse this list for R and RStudio
    ];
    patchedQuarto = (pkgs.quarto.override {
        extraPythonPackages = myPythonPackages;
        extraRPackages = myRPackages;
      });#.overrideAttrs (oldAttrs: { # Remove this overrideAttrs patch when fixed. See https://github.com/NixOS/nixpkgs/issues/519484#issuecomment-4667477454
      #postPatch = (oldAttrs.postPatch or "") + ''
      #  substituteInPlace bin/quarto.js \
      #    --replace-fail "syntax-highlighting" "highlight-style"
      #'';
    #})
  in with pkgs; [
    vim
    wget
    gparted
    gnome-disk-utility
    cryptomator
    fzf
    #nix stuff
    nix-search-tv
    nixd
    #misc
    xsettingsd
    xrdb
    libreoffice-qt
    ivpn-ui
    #### next generation of Rmarkdown for Python, Julia, R, and JS:
    patchedQuarto
    #### Your command-line Python:
    (python3.withPackages (myPythonPackages))
    #### R and RStudio:
    (rWrapper.override {packages = myRPackages; })
    (rstudioWrapper.override { packages = myRPackages; })
    #### LaTeX
    texliveFull
  ];

  fonts.packages = with pkgs; [
  noto-fonts
  noto-fonts-cjk-sans
  noto-fonts-color-emoji
  liberation_ttf
  fira-code
  fira-code-symbols
  corefonts
  vista-fonts
];

  services.ivpn.enable = true;

  # Garbage collection (delete old generations)
  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 7d";
};

  #stylix = {
  #enable = true;
  #base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  #};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .

}
