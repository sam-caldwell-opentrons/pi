 # Raspberry-Probe
 =================

# Purpose
Use `packer` to automate the process for creating Raspberry Pi images,
then use that automation to produce raspberry-pi based probe devices.

# Usage
* This project will build images using Github Actions and the images will 
  be stored in releases.
* Changes are build per branch.
* Manual images can be build using `make images`.

# Development
* Run `make setup` to install dependencies (including the packer plugin)
* Run `make images` to build the images.

# Credits
* This project is based on the work by--
  * [
     Linuxhit: Build a Raspberry Pi image with Packer – packer-builder-arm
    ](https://linuxhit.com/build-a-raspberry-pi-image-packer-packer-builder-arm/)
  * Muller, Florian. [
    Raspberry Development Environment on MacOSX with QEMU
    ](https://florianmuller.com/raspberry-development-environment-on-macosx-with-qemu) 
