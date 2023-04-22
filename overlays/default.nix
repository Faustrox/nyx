# Conventions:
# - Sort packages in alphabetic order.
# - If the recipe uses `override` or `overrideAttrs`, then use callOverride,
#   otherwise use `final`.
# - Composed names are separated with minus: `input-leap`
# - Versions/patches are suffixed with an underline: `mesa_git`, `libei_0_5`, `linux_hdr`
# - Use `inherit (final) nyxUtils` since someone might want to override our utils

# NOTE:
# - `*_next` packages will be removed once merged into nixpkgs-unstable.

{ inputs }: final: prev:
let
  nyxUtils = final.callPackage ../shared/utils.nix { };

  callOverride = path: attrs: import path ({ inherit final inputs nyxUtils prev; } // attrs);

  callOverride32 = path: attrs: import path ({
    inherit inputs nyxUtils;
    final = final.pkgsi686Linux;
    prev = prev.pkgsi686Linux;
  } // attrs);
in
{
  inherit nyxUtils;

  ananicy-cpp-rules = final.callPackage ../pkgs/ananicy-cpp-rules { };

  applet-window-appmenu = final.libsForQt5.callPackage ../pkgs/applet-window-appmenu { };

  applet-window-title = final.callPackage ../pkgs/applet-window-title { };

  appmenu-gtk3-module = final.callPackage ../pkgs/appmenu-gtk3-module { };

  beautyline-icons = final.callPackage ../pkgs/beautyline-icons { };

  directx-headers_next = callOverride ../pkgs/directx-headers-next { };

  directx-headers32_next =
    if final.stdenv.hostPlatform.isLinux && final.stdenv.hostPlatform.isx86
    then
      callOverride32 ../pkgs/directx-headers-next { }
    else throw "No headers32_next for non-x86";

  firedragon-unwrapped = final.callPackage ../pkgs/firedragon { };

  firedragon = final.wrapFirefox final.firedragon-unwrapped {
    inherit (final.firedragon-unwrapped) extraPrefsFiles extraPoliciesFiles;
    libName = "firedragon";
  };

  dr460nized-kde-theme = final.callPackage ../pkgs/dr460nized-kde-theme { };

  gamescope_git = callOverride ../pkgs/gamescope-git { };

  input-leap_git = callOverride ../pkgs/input-leap-git {
    libei = final.libei_0_4;
    qttools = final.libsForQt5.qt5.qttools;
  };

  libei_0_4 = final.callPackage ../pkgs/libei {
    libeiVersion = "0.4.1";
    libeiSrcHash = "sha256-wjzzOU/wvs4QeRCQMH56TARONx+LjYFVMHgWWM/XOs4=";
  };
  libei_0_5 = final.callPackage ../pkgs/libei { };
  libei = final.libei_0_5;

  linux_cachyos = final.callPackage ../pkgs/linux-cachyos {
    kernelPatches = with final.kernelPatches; [
      bridge_stp_helper
      request_key_helper
    ];
  };

  linux_hdr = final.callPackage ../pkgs/linux-hdr {
    kernelPatches = with final.kernelPatches; [
      bridge_stp_helper
      request_key_helper
    ];
  };

  linuxPackages_cachyos = final.linuxPackagesFor final.linux_cachyos;

  linuxPackages_hdr = final.linuxPackagesFor final.linux_hdr;

  mesa_git = callOverride ../pkgs/mesa-git {
    directx-headers = final.directx-headers_next;
  };
  mesa32_git =
    if final.stdenv.hostPlatform.isLinux && final.stdenv.hostPlatform.isx86
    then
      callOverride32 ../pkgs/mesa-git
        {
          directx-headers = final.directx-headers32_next;
        }
    else throw "No mesa32_git for non-x86";

  sway-unwrapped_git =
    nyxUtils.gitOverride inputs.sway-git-src
      (prev.sway-unwrapped.override {
        wlroots_0_16 = final.wlroots_git;
        wayland = final.wayland_next;
      });
  sway_git = prev.sway.override {
    sway-unwrapped = final.sway-unwrapped_git;
  };

  wayland_next = prev.wayland.overrideAttrs (_: rec {
    version = "1.22.0";
    src = final.fetchurl {
      url = "https://gitlab.freedesktop.org/wayland/wayland/-/releases/${version}/downloads/wayland-${version}.tar.xz";
      hash = "sha256-FUCvHqaYpHHC2OnSiDMsfg/TYMjx0Sk267fny8JCWEI=";
    };
  });

  waynergy_git = nyxUtils.gitOverride inputs.waynergy-git-src prev.waynergy;

  wlroots_git = callOverride ../pkgs/wlroots-git {
    wayland = final.wayland_next;
  };
}
