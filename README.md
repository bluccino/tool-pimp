![Info Database](./etc/pimp.jpg)

--------------------------------------------------------------------------------

# Pimping Virtual Environments

## Curl Installation Formula

In a `bash` shell with installed `curl` execute the following one-line command
to download and install `pimp`. Select a number from the list of potential
install directories (which are extracted from your PATH).

```sh
  HUB=https://raw.githubusercontent.com/bluccino; \
      curl -s $HUB/tool-pimp/master/bin/pimp >~pimp; bash ~pimp -!
```

Tool `pimp` provides a self check option.

```sh
  $ pimp --check
  checking system requirements ...
    OK: Git version managing tool (git)
    OK: Python version (Python 3.12.2)
    OK: Python package manager (pip)
    OK: virtual Python environments (venv)
```

I any of the checked items is not marked with `OK` it is strongly suggested to
fix such issue first by consulting the appendix.


## Pimp Basics

`pimp` is a `bash` script to pimp a virtual (Python) environment in two
aspects:

* modifying the `activate` script of the virtual python environment in order
  to source a `setup.sh` script at the end of the activation process, and modifying
  the deactivate function (which the activation installs) in order to source
  a `cleanup.sh` script before the actual deactivation

* optionally adding executable binary files (typically bash scripts) to the
  virtual environment's binary folder, which are only "available" (executable) as long as the
  virtual environment is activated.

~~~
    NOTE: In a typical scenario the set of binary files, which are copied to the
    virtual environment's binary folder, include the `setup.sh` and `cleanup.sh`
    scripts which the activation and deactivation should implicitely call.
~~~


## Building Virtual Environments

Since virtual environments should (usually) not be included in git repositories,
they need to be built and setup with Python packages and shell scripts according
to a build recipe. `pimp` supports such build process controlled by recipe
files located in a hidden `.pimp` directory. The command line below
demonstrates a sample initialization of `.pimp` directory for building a
virtual envioronment `@venv` with skeleton `setup.sh`/`cleanup.sh` scripts.

```sh
    $ mkdir .../path-to;  cd .../path-to  # create/change to a playground directory
```
```sh
    path-to $ pimp --init @venv  # init a .pimp folder for build-up of @venv
    === initializing .pimp directory ...
    path-to $ tree .pimp
    .pimp
    ├── bin
    │   ├── cleanup.sh
    │   └── setup.sh
    ├── consign
    ├── deploy
    ├── init.sh
    └── venv
```

After `.pimp` is initialized, command `. pimp` creates virtual environment
`@venv`, pimps the `@venv/bin/activate` script, installs scripts `setup.sh` and
`cleanup.sh` and activates the virtual environment.

```sh
    path-to $ . pimp
    virtual environment not existing!
    shall I create virtual environment @venv [Y/n]?Y
    === creating virtual environment @venv ...
    === pimping @venv/bin/activate
    there is a consignment file (.pimp/consign)
    shall I consign binaries and install in @venv [Y/n]?Y
    pimp --consign
    === consigning files (=> /Users/hux/Bluenetics/Git/Tmp/.pimp/bin)
    === copy consigned binaries to virtual environment
      path-to/.pimp/bin/cleanup.sh -> @venv/bin
      path-to/.pimp/bin/setup.sh -> @venv/bin
    === post initialize virtual environment (run .pimp/init.sh)
      post init of @venv ...
    === pimping complete
    === setup virtual environment ...
    (@venv) path-to $
```


## Pimp and West

`west` can be used in general for workspaces which are not related to Zephyr, but
most `west` applications are related to Zephyr. One specific use case of pimp is
to modify a virtual environment of a west workspace containing the zephyr tree.
A specific task is to set the environment variable `ZEPHYR_BASE`, when the
virtual environment is activated, and to unset in the deactivation case
(setting ZEPHYR_BASE is vital for bilding freestanding applications). In such
use case the pimp can automatically prepare proper `setup`/`cleanup` scripts.

```sh
    #!/bin/bash
    # setup (setup script for virtual environment)

    echo '=== setup virtual environment ...'
    export ZEPHYR_BASE=/path-to/zephyr
```

```sh
		#!/bin/bash
		# cleanup (cleanup script for virtual environment)

		echo '=== cleanup virtual environment ...'
		unset ZEPHYR_BASE
```

Pimp has a special feature (option `--zephyr`) to pimp a virtual environment
of a west/zephyr workspace which is demonstrated in the following example,
showcasing installation of Zephyr version 3.5.0

```sh
    ... $ mkdir z3.5.0; cd z3.5.0
    z3.5.0 $ pimp --init @z3.5.0              # init .pimp with setup/cleanup scripts
    z3.5.0 $ pimp --zephyr                    # extend setup/cleanup for zephyr
    z3.5.0 $ . pimp                           # create/pimp/activate virtual environment
    (@z3.5.0) z3.5.0 $ pip install west       # install west (Python) package in @z3.5.0
    (@z3.5.0) z3.5.0 $ west init -mr v3.5.0   # init for specific version
    (@z3.5.0) z3.5.0 $ west update            # update zephyr installation
```



## Pre-Requisites

Pre-requisites for `pimp` is a `bash` environment (as supported by Linux,
Mac-OS and Windows/WSL) with `python` and `pip` running. At the time of writing
`pimp` was tested on a Mac computer with the following installation:

```sh
    $ python --version
    Python 3.11.7
    $ pip --version
    pip 24.0 from ...
```

Availability of `tree` is helpful for following the tutorial but not
absolutely necessary. With `curl` installed the next section shows an easy way
to download and install `pimp`. On the other hand cloning the `pimp` repository
from github will also do the job (`pimp` is located in the repository's
subfolder `bin`).

```sh
    $ git clone https://github.com/bluccino/tools-pimp  # see tools-pimp/bin/pimp
```


# Tutorial 1: Create Pimped Virtual Environment

In this tutorial let us consider the following tasks:

* creation of a workspace folder `my-ws` with virtual environment folder `@my-ws`
* on activation of `@venv` a message 'hello, @my-ws' shall be printed,
  and an alias `la` shall be defined as `ls -a`.  
* on deactivation of `@venv` a message 'good bye, @my-env' shall be printed,
and alias `la` shall be unset.  


## Creating a Workspace Folder with a Virtual Environment

To avoid confusion we distinguish the name of the virtual environment folder
(`@my-ws`) from the workspace root folder (`my-ws`) by a leading `@` character.
In this sense the following command sequence will perform the first task.

```sh
    ... $ mkdir path-to/my-ws    # create folder
    ... $ cd path-to/my-ws       # change directory to my-ws
    my-ws $ python3 -m venv @my-ws
```

Note that the virtual environment at this time is not activated. So far we got
the following file tree:

```sh
    tree --dirsfirst -a -L 2
    .
    └── @my-ws
        ├── bin
        ├── include
        ├── lib
        └── pyvenv.cfg
```

The activation script for the virtual environment is located at
`@my-ws/bin/activate`. This script must be sourced in order to modify the
current `bash` environment. A short activation/deactivation test proofs that
everything works well. Note that after activation a `(@my-ws)` string is shown
at the beginning of the prompt, which disappears upon deactivation.

```sh
    my-ws $ source @my-ws/bin/activate  # script must be sourced for activation
    (@my-ws) my-ws $ deactivate         # undo environment modifications
    my-ws $
```

## Creation of Scripts `setup.sh` and `cleanup.sh`

In a first step we will create a hidden `.pimp` folder where all stuff that
`pimp` needs will be located. Next we create a `.pimp/bin` folder to contain all
scripts which `pimp` should install into `@my-ws/bin`.

```sh
    mkdir .pimp       # a hidden folder with all stuff that pimp needs
    mkdir .pimp/bin   # for binaries which should be installed in @my-ws/bin
```

The `setup.sh` script echos the message 'hello, @my-ws' and defines alias `al`.

```sh
    my-ws $ echo "echo 'hello, @my-ws'" >.pimp/bin/setup.sh
    my-ws $ echo "alias la='ls -a'" >>.pimp/bin/setup.sh  # append
```

The plan is to source `setup.sh` during activation, thus, for testing we also need
to source.

```sh
    my-ws $ cat .pimp/bin/setup.sh    # let's see the content of script setup.sh
    echo 'hello, @my-ws'
    alias la='ls -a'
    my-ws $ source .pimp/bin/setup.sh  # test script setup (we need to source)
    hello, @my-ws
    my-ws $ la  # test alias
    .	..	.pimp	@my-ws
```

That works well! Let's create script `cleanup.sh`.

```sh
    my-ws $ echo "echo 'good bye, @my-ws'" >.pimp/bin/cleanup.sh
    my-ws $ echo "unalias la" >>.pimp/bin/cleanup.sh  # append
```

For similar reasons we need to source `cleanup.sh` for testing. When we invoke
alias `la` after sourcing `cleanup.sh` we expect that `bash` reports an error,
since the alias should be removed.

```sh
    my-ws $ cat .pimp/bin/cleanup.sh    # let's see the content of cleanup
    echo 'good bye, @my-ws'
    unalias la
    my-ws $ source .pimp/bin/cleanup.sh  # test script cleanup (we need to source)
    good bye, @my-ws
    my-ws $ la  # test alias
    -bash: la: command not found
```

Perfect, we completed the creation of the two scripts and proofed them to work
correctly.


## Pimping the Virtual Environment

When we `pimp` the virtual environment we need to do two steps:

~~~
    Step 1: We need to modify script @my-env/bin/activate, in order to implicitely
            source setup.sh/cleanup.sh upon activation/deactivation of @my-ws
~~~

How does `@my-ws/bin/activate` know where `setup.sh` and `cleanup.sh` are located?
In `.pimp/bin` ? The answer is no! The scripts are expected to be in the virtual
environment's binary directory `@my-ws/bin`. If one of them is missing, it is
also OK and no error is reported.

The first action (pimping the `activate` script) is achieved by the following
command line:

```sh
    my-ws $ pimp @my-ws   # pimp @my-ws/bin/activate script
```

Since `activate` defines also the `deactivate` function, this command pimps
also `deactivate` in order to source the `@my-env/bin/cleanup.sh` script, which is
ignored wthout error if missing. All in all we require pimp to do also
the second action.

~~~
    Step 2: We need to install (copy) our prepared scripts setup and cleanup
            in the virtual environment's binary folder
~~~

This is done by

```sh
    my-ws $ pimp @my-ws .pimp/bin   # copy all files in .pimp/bin to @my-ws
```

which copies all files located in `.pimp/bin` to the virtual environment's
binary folder `@my-ws/bin`. This would give us the opportunity to provide
additional binaries in `.pimp/bin` which would be installed by `pimp` in the
virtual environment's binary directory, and thus, only be executable as long as
the virtual environment is activated.

~~~
    NOTE: In fact, command `pimp <venv> <bin>` does not only install the
    binaries in <bin> (step 2), it also performs step 1, if this has not
    yet been done before.
~~~  

## Final Check

As a pre-check we list the virtual environment's binary directory and verify
the copies of `setup.sh` and `cleanup.sh`.

```sh
    my-ws $  tree @my-ws/bin
    @my-ws/bin
    ├── activate
    :       :
    ├── setup.sh
    └── cleanup.sh

    1 directory, 12 files
```

Then we activate the virtual environment, cross check the 'hello message' and
verify that alias `la` is working.

```sh
    my-ws $ source @my-ws/bin/activate
    hello, @my-ws
    (@my-ws) my-ws $ la   # test alias
    .	..	.pimp	@my-ws
```

Finally we test deactivation and expect `bash` to issue an error message when we
invoke alias `la`.

```sh
    (@my-ws) my-ws $ deactivate
    good bye, @my-ws
    my-ws $ la   # test alias
    -bash: la: command not found
```

# Conclusions

* `pimp` is a `bash` based script, arranging execution of a custom `setup.sh`
  script at the end of the activation of a virtual environment
* `pimp` also arranges execution of a custom `cleanup.sh` script at the begin of
  deactivation of a virtual environment.
* `pimp` does this by modifying the `bin/activate` script of a virtual
  environment
* `pimp`can optionally also consulted for installation of some prepared binaries
  in a virtual environment's binary folder
* there is a simple curl-formula for downloading the `pimp` script, which can
  subsequently be copied into a binary folder of choice.


# Tutorial 5: Selectable Zephyr Workspaces

Before installing a *Zephyr Workspace* install the Zephyr development kit as
described on *Getting Started* guide of the *Zephyr Project* website
(https://docs.zephyrproject.org/latest/develop/getting_started/index.html#).

We suggest to install all Zephyr distributions in a directory `/opt/zephyr` owned by the user.

```sh
  ~ $ sudo mkdir /opt/zephyr             # initially owned by root
  ~ $ sudo chown $(whoami) /opt/zephyr   # change ownership
```

Further we suggest to name all Zephyr workspace directories beginning with letter
`z` followed by the revision number (e.g. `z3.6.99` for latest revision and
`z3.6.0` for a specific revision). With such convention there is no name collision
with Nordic naming conventions, which are begining a Zephyr workspace directory
with letter `v` followed by the revision number (e.g. `v2.5.2`, `v2.6.0`)

To install a *pimped Zephyr* workspace we suggest to perform the following steps:

* Creating a Zephyr workspace directory (topdir)
* Creating and activating a pimped virtual environment (in the topdir)
* Initializing the `west` workspace
* Updating the `west` workspace
* Installing requirements related to the specific Zephyr tree


## Installing a Zephyr Project Distribution

### 1) Creating a Zephyr Workspace Directory

```sh
  ~ $ mkdir /opt/zephyr/z3.6.99 && cd /opt/zephyr/z3.6.99
  z3.6.99 $  
```

Note that the Zephyr workspace topdir `/opt/zephyr/z3.6.99` relates to directory
`zephyrproject` in the *Getting Started* documentation of the Zephyr website.


### 2) Creating and Activating a Pimped Virtual Environment

```sh
  z3.6.99 $ pimp -i @z3.6.99     # prepare a virtual environment @z3.6.99
  z3.6.99 $ pimp -z              # prepare a Zephyr workspace
  z3.6.99 $ . pimp               # run pimp process
  ...
  (@z3.6.99) z3.6.99 $
```

The `. pimp` process automatically installs `west` (to be confirmed). 


### 3) Initializing the West Workspace

To install the latest revision of the Zephyr workspace:

```sh
   (@z3.6.99) z3.6.99 $ west init
   ...
```

To install a Zephyr workspace with a specific revision (e.g. `v3.6.0`) a
workspace directory with different name (`/opt/zephyr/z3.6.0`) and virtual
environment directory `/opt/zephyr/z3.6.0/@z3.6.0` would have been created.
The initializing command would then be:

```sh
   (@z3.6.0) z3.6.0 $ west init -mr v3.6.0
   ...
```

### 4) Updating the Zephyr Workspace

```sh
  (@z3.6.0) z3.6.0 $ west update
  ...
```

### 5) Installing Requirements Related to Zephyr Tree

```sh
  (@z3.6.99) z3.6.99 $ pimp -r  # install Zephyr tree related requirements
```

To test the installation (note: Zephyr SDK needs to be installed):

```sh
  (@z3.6.99) z3.6.99 $ cd zephyr/samples/hello_world
  (@z3.6.99) hello_world $ export BOARD=qemu_cortex_m3
  (@z3.6.99) hello_world $ west build -t run
  ...
  Hello World! qemu_cortex_m3
```


## Final Remarks

Pimping a Zephyr workspace can be done also, after the west workspace has been
already initialized and updated. This is shown below for specific Zephyr
revision `z3.6.0` and `west` is installed in some global virtual environment
`@tools`.

```sh
  (@tools) z3.6.0 $ west init -mr v3.6.0
  ...
  (@tools) z3.6.0 $ west update
  ...
  (@tools) z3.6.0 $ pimp -r  # install Zephyr tree related requirements
  ...
```

With above commands the Zephyr workspace revision `v3.6.0` is installed (but not
pimped). The post-pimping procedure is as follows.

```sh
  (@tools) z3.6.0 $ pimp -i @z3.6.0
  === initializing .pimp directory
  (@tools) z3.6.0 $ pimp -z
  === pimping .pimp for zephyr
  (@tools) z3.6.0 $ . pimp             # run pimp process
  ...
```

The last command to install west in `@z3.6.0` is necessary if `west` is not
installed in a system Python installation. The same procedure can be applied to
a *Nordic Zephyr Installation*, which has been installed with the
*nRF Connect Toolchain Manager*. The procedure (applied to `v2.5.2` revision)
looks as follows.

```sh
  ~ / cd /opt/nordic/ncs/v2.5.2        # navigate to Nordic Zephyr workspace
  v2.5.2 $ pimp -i @v2.5.2
  === initializing .pimp directory
  v2.5.2 $ pimp -z
  === pimping .pimp for zephyr
  v2.5.2 $ . pimp             # run pimp process
```




# Appendix - Fixing Installation Issues

`pimp` can check the system requirements in a limited extent.

```sh
  (@ws) tool-pimp $ pimp --check
  checking system requirements ...
    OK: Git version managing tool (git)
    OK: Python version (Python 3.12.2)
    OK: Python package manager (pip)
    OK: virtual Python environments (venv)
```

If one of the requirements fails we recommend to consult the first two sections
of the *Getting Started* guide of the *Zephyr Project* website
(https://docs.zephyrproject.org/latest/develop/getting_started/index.html#).

* *Select and Update OS*
* *Install Dependencies*

At the time of writing (Zephyr v3.6.99) this documentation provides the
following guidance.


## Select an Update OS on Ubuntu Platform

Run the following commands:

```sh
  sudo apt update
  sudo apt upgrade  
```

## Install Dependencies on Ubuntu Platform

If using an Ubuntu version older than 22.04, it is necessary to add extra
repositories to meet the minimum required versions for the main dependencies
listed above. In that case, download, inspect and execute the Kitware archive
script to add the Kitware APT repository to your sources list. A detailed
explanation of kitware-archive.sh can be found here kitware third-party apt
repository:

```sh
  wget https://apt.kitware.com/kitware-archive.sh
  sudo bash kitware-archive.sh
```

Use apt to install the required dependencies:

```sh
  sudo apt install --no-install-recommends git wget
  sudo apt install --no-install-recommends python3-dev python3-pip python3-setuptools
  sudo apt install --no-install-recommends python3-tk python3-wheel
```


## Select an Update OS on MacOS Platform

On macOS Mojave or later, select System Preferences > Software Update.
Click Update Now if necessary.


## Install Dependencies on MacOS Platform

Install Homebrew:

```sh
  HUB=https://raw.githubusercontent.com/Homebrew; \
      /bin/bash -c "$(curl -fsSL $HUB/install/HEAD/install.sh)"
```

After the Homebrew installation script completes, follow the on-screen instructions to add the Homebrew installation to the path.

* On macOS running on Apple Silicon, this is achieved with:

```sh
     (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.bash_profile
     source ~/.bash_profile
```

* On macOS running on Intel, use the this command:

```sh
     (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> ~/.bash_profile
     source ~/.bash_profile
```

Use brew to install the required dependencies:

```sh
  brew install cmake ninja gperf python3 ccache qemu dtc libmagic wget openocd
```

Add the Homebrew Python folder to the path, in order to be able to execute python and pip as well python3 and pip3.

```sh
  (echo; echo 'export PATH="'$(brew --prefix)'/opt/python/libexec/bin:$PATH"') \
    >> ~/.bash_profile
  source ~/.bash_profile
```
