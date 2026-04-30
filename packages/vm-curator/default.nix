{ lib, rustPlatform, fetchFromGitHub, pkg-config, udev }:

rustPlatform.buildRustPackage {
  pname = "vm-curator";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "mroboff";
    repo = "vm-curator";
    rev = "v0.4.7";
    hash = "sha256-Nyq/i/MS24+5AaKs6mrsdmjO2BttqVzlLqIL6QEy1OA=";
  };

  patches = [ ./nixos-fixes.patch ];

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];

  meta = {
    description = "TUI application to manage QEMU VM library";
    homepage = "https://github.com/mroboff/vm-curator";
    license = lib.licenses.mit;
    mainProgram = "vm-curator";
  };
}
