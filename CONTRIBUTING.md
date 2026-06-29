# Contributing

## Requirements

- FreeBSD 13.0+ with `linux_base-rl9` installed
- A working ports tree (`/usr/ports` or a local overlay)

## Updating the port to a new Zen Browser version

1. Update `PORTVERSION` in `Makefile`
2. Download the new tarball and regenerate checksums:
   ```sh
   make distclean
   make fetch
   make makesum
   ```
3. Test the build:
   ```sh
   doas make install clean
   ```
4. Verify the plist is still accurate:
   ```sh
   make check-plist
   ```
5. Open a PR with `distinfo` and `Makefile` updated.

## Testing a local change

Always test with a clean build to catch missing files or broken stubs:

```sh
doas make deinstall
doas make install clean
zen-browser &
```

Check that:
- The browser launches without errors in the terminal
- A page with audio plays correctly (e.g. YouTube)
- System notifications work if you changed `libnotify` handling

## Stub libraries

The stub `.so` files are compiled from `files/stubs.mk`. They are minimal shared objects that satisfy `libavcodec.so.59`'s link-time dependencies without providing real functionality. If you need to add or remove a stub, edit `files/stubs.mk` and `pkg-plist` accordingly.

## Reporting issues

Use the issue templates — they ask for the specific output (`kldstat`, build log) needed to diagnose FreeBSD compat layer problems quickly.

## Code style

Follow existing `Makefile` conventions from the FreeBSD Ports Handbook. Keep the wrapper script POSIX-compatible (`/bin/sh`).
