{
  description = "Project Asleh";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    android.url = "github:tadfisher/android-nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = { self, nixpkgs, devshell, flake-utils, android, rust-overlay, naersk }:
    {
      overlay = final: prev: {
        inherit (self.packages.${final.system}) android-sdk;
      };
    }
    //
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            devshell.overlays.default
            self.overlay
            (import rust-overlay)
          ];
        };

        naersk' = pkgs.callPackage naersk {};

        android-sdk = android.sdk.${system} (sdkPkgs: with sdkPkgs; [
          # Useful packages for building and testing.
          build-tools-35-0-0
          cmdline-tools-latest
          platform-tools
          platforms-android-36
          ndk-29-0-13113456
        ]);
        buildForTarget = target: naersk'.buildPackage {
          src = ./asleh-rs;
          cargoBuildFlags = [
            "--release"
            "--lib"
            #"--no-default-features"
          ];
          CARGO_BUILD_TARGET = target;

          ANDROID_HOME = "${android-sdk}/share/android-sdk";
          ANDROID_SDK_ROOT = "${android-sdk}/share/android-sdk";
          ANDROID_NDK_ROOT = "${android-sdk}/share/android-sdk/ndk";
          JAVA_HOME = pkgs.jdk17.home;

          CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER = "${android-sdk}/29.0.13113456/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android24-clang";

          buildInputs = [
            android-sdk
            (pkgs.rust-bin.stable.latest.default.override {
              extensions = [ "rust-src" ];
              targets = [ target ];
            })
          ];
        };
      in
      rec {
        packages = {
          android-sdk = android.sdk.${system} (sdkPkgs: with sdkPkgs; [
            # Useful packages for building and testing.
            build-tools-35-0-0
            cmdline-tools-latest
            platform-tools
            platforms-android-36
            ndk-29-0-13113456
          ]);
          asleh-x86_64-android = buildForTarget "x86_64-linux-android";
          asleh-i686-android = buildForTarget "i686-linux-android";
          asleh-armv7 = buildForTarget "armv7-linux-androideabi";
          asleh-aarch64 = buildForTarget "aarch64-linux-android";

          asleh-rs = pkgs.rustPlatform.buildRustPackage rec {
            pname = "asleh-rs"; 
            version = "0.0.1"; 
            src = ./asleh-rs; 
            cargoBuildFlags = [ 
                 "--lib" 
                 "--release"
                 "--target" "x86_64-linux-android"
                 "--target" "i686-linux-android"
                 "--target" "armv7-linux-androideabi"
                 "--target" "aarch64-linux-android"
            ];
             cargoLock.lockFile = ./asleh-rs/Cargo.lock;
            buildInputs = [
              android-sdk
              (pkgs.rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "arm-unknown-linux-gnueabihf" "aarch64-linux-android" "armv7-linux-androideabi" "x86_64-linux-android" "i686-linux-android" ];
              })
            ];

          }; 

          asleh = naersk'.buildPackage {
            src = ./asleh-rs;
            cargoBuildFlags = [
              "--lib"
              "--release"
              #"--no-default-features"
              # Add this line to enable the feature for the bindgen tool
              #"--features" "uniffi/bindgen" 
              "--target" "x86_64-linux-android"
              "--target" "i686-linux-android"
              "--target" "armv7-linux-androideabi"
              "--target" "aarch64-linux-android"
            ];
            #CARGO_BUILD_TARGET = rustTarget;
            buildInputs = [ 
              (pkgs.rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "arm-unknown-linux-gnueabihf" "aarch64-linux-android" "armv7-linux-androideabi" "x86_64-linux-android" "i686-linux-android" ];
              })
            ];
          };

          release =  pkgs.stdenv.mkDerivation {
            name = "asleh-release";

            impureEnvVars = [
              "KEYSTORE_BASE64"
              "KEYSTORE_PASSWORD"
              "KEY_ALIAS"
              "KEY_PASSWORD"
            ];

            src = ./.;

            buildInputs = with pkgs;  [
              android-sdk 
              gradle 
              jdk17

              (rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "arm-unknown-linux-gnueabihf" "aarch64-linux-android" "armv7-linux-androideabi" "x86_64-linux-android" "i686-linux-android" ];
              })
            ];

            ANDROID_HOME = "${android-sdk}/share/android-sdk";
            ANDROID_SDK_ROOT = "${android-sdk}/share/android-sdk";
            ANDROID_NDK_ROOT = "${android-sdk}/share/android-sdk/ndk";
            JAVA_HOME = pkgs.jdk17.home;

            buildPhase = ''
              set -e
              cd asleh-rs

               cargo build --release --lib \
                --target x86_64-linux-android \
                --target i686-linux-android \
                --target armv7-linux-androideabi \
                --target aarch64-linux-android

              mkdir -p ../app/src/main/jniLibs/arm64-v8a/
              cp target/aarch64-linux-android/release/libasleh.so ../app/src/main/jniLibs/arm64-v8a/libuniffi_asleh.so

              mkdir -p ../app/src/main/jniLibs/armeabi-v7a/
              cp target/armv7-linux-androideabi/release/libasleh.so ../app/src/main/jniLibs/armeabi-v7a/libuniffi_asleh.so

              mkdir -p ../app/src/main/jniLibs/x86/
              cp target/i686-linux-android/release/libasleh.so ../app/src/main/jniLibs/x86/libuniffi_asleh.so

              mkdir -p ../app/src/main/jniLibs/x86_64/
              cp target/x86_64-linux-android/release/libasleh.so ../app/src/main/jniLibs/x86_64/libuniffi_asleh.so

              cargo run --features=uniffi/cli \
                --bin uniffi-bindgen \
                generate src/asleh.udl \
                --language kotlin

              mv src/uniffi ../app/src/main/java/

              cd ../app
              echo "$KEYSTORE_BASE64" | base64 -d > key.jks

              cd ../

              chmod -w local.properties
              chmod +x ./gradlew
              ./gradlew assembleRelease

            '';

            installPhase = ''
              mkdir -p $out/bin
              cp app/build/outputs/apk/release/app-release.apk $out/bin/
            '';
          };
        };

        devShell = import ./devshell.nix { inherit pkgs; };
      }
    );
}

