# Nim-CrossCompile

Crosscompile Nim source code into multiple targets on Linux with this proc.


# Support

- **By default it only supports Arch Linux**, if you need to use it on another Operating System use VirtualBox or Docker with Arch Linux in it.
- Another option is to adapt the source code to your Operating System, but that is not supported by default.


# Requisites

Linux -> Windows CrossCompile, this allows to generate a `*.EXE` for Windows on Linux.

On Linux install all this packages:

```
mingw-w64-binutils mingw-w64-crt mingw-w64-gcc mingw-w64-headers mingw-w64-winpthreads mingw-w64-gcc-base mingw-w64-*
```

Usually only installing `mingw-w64-gcc` gets all the rest as dependency.

Names are from ArchLinux AUR, should be similar on other Distros.

Requires NodeJS installed, for JavaScript Compilation.

If you have problems running the Compilation because of your Distro using too old packages (Debian old stable, etc),
then use a Docker with Arch Linux and run the app inside of the Docker.

If you know how to Dockerize the App, Pull Requests are welcome.
