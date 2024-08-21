# Build No Invitation demo

Source: https://github.com/ninjadev/revision-invite-2018

## Prerequisites

- Linux
- node.js and npm installed (if baremetal build)
- docker installed (if docker build)
- [GNU Make](https://www.gnu.org/software/make/)

## Usage

Clone this repo with its submodule (the [revision-invite-2018](https://github.com/ninjadev/revision-invite-2018) repo)

```bash
git clone --recurse-submodules https://github.com/eric-glb/build-revision-invite-2018.git 
```

Then use Make targets:

```bash
make help
```

```text
  make [ help | all | prerequisites | build | run | serve | clean |
         docker-build | docker-run | docker-build-dev | docker-run-dev | docker-stop |
         docker-clean | clean-all ]
```

Cf. [Makefile](./Makefile) to see the targets details.


NB: for baremetal build, change the npm packages installation location (e.g. [here](https://vasu-vanka.medium.com/npm-change-package-installation-location-73350ec42761)) 

## Demo

![Screenshots](assets/make.gif)

