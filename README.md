# Overview

Welcome to my MSYS2 dotfiles repository! This repository contains my dotfiles and a setup script to quickly establish a MSYS2 development environment. Currently, I only support the UCRT64 environment, as that is what I am most familiar with. However, setting up a different environment is straightforward — simply create a `packages.mingw32.txt` file (or similar) and list your desired packages.

The `install.sh` script performs several key tasks:

- Installs the packages specified in the corresponding `packages.txt` file for your current MSYS2 environment.
- Copies the dotfiles to their appropriate locations.
- Generates or locates SSH and GPG keys, and configures Git to use them.

# Installation

To install the dotfiles into the current directory, run the following commands:

```
git clone https://github.com/mrtoodamnjustin/MSYS2-Dotfiles.git dotfiles/
cd dotfiles/
./install.sh
```

