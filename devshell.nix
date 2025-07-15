{ pkgs }:

with pkgs;

# Configure your development environment.
#
# Documentation: https://github.com/numtide/devshell
devshell.mkShell {
  name = "android-project";
  motd = ''
    Entered the Android app development environment.
  '';
  env = [
    {
      name = "ANDROID_HOME";
      value = "${android-sdk}/share/android-sdk";
    }
    {
      name = "ANDROID_SDK_ROOT";
      value = "${android-sdk}/share/android-sdk";
    }
    {
      name = "ANDROID_NDK_ROOT";
      value = "${android-sdk}/share/android-sdk/ndk";
    }
    {
      name = "JAVA_HOME";
      value = jdk17.home;
    }
  ];
  packages = [
    android-sdk
    gradle
    jdk17
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
      targets = [ "arm-unknown-linux-gnueabihf" "aarch64-linux-android" "armv7-linux-androideabi" "x86_64-linux-android" "i686-linux-android" ];
    })
  ];
}

