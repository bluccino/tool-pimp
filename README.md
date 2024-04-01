![Info Database](./etc/pimp.jpg)

--------------------------------------------------------------------------------

# Pimping Virtual Environments

## Curl Installation Formula

In a `bash` shell with installed `curl` execute the following one-line command
to download and install `pimp`. Select a number from the list of potential
install directories (which are extracted from your PATH).

```
  curl -s https://raw.githubusercontent.com/bluccino/tool-pimp/master/bin/pimp >~pimp; bash ~pimp -!
```


## Pimp Basics

`pimp` is a `bash` script to pimp a virtual (Python) environment in two
aspects:

* modifying the `activate` script of the virtual python environment in order
  to source a `setup.sh` script at the end of the activation process, and modifying
  the deactivate function (which the activation installs) in order to source
  a `cleanup.sh` script before the actual deactivation

* optionally adding executable binary files (typically bash scripts) to the
  virtual environment's binary folder, which are only available as long as the
  virtual environment is activate.

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

```
    $ pimp --init @venv  # init a .pimp folder for build-up of @venv
    === initializing .pimp directory ...
    $ tree .pimp
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
`@venv`, pimps the `@venv/bin/activate` script, installs scripts `setup` and
`cleanup` and activates the virtual environment.

```
    path-to $ . pimp
    virtual environment not existing!
    shall I create virtual environment @venv [Y/n]?
    === creating virtual environment @venv ...
    === pimping @venv/bin/activate
    === consigning files (=> /Users/hux/Bluenetics/Git/Tmp/.pimp/bin)
    === copy consigned binaries to virtual environment
      path-to/.pimp/bin/cleanup -> @venv/bin
      path-to/.pimp/bin/setup -> @venv/bin
    === post initialize virtual environment (run .pimp/init.sh)
      post init of @venv ...
    === pimping complete
    === setup virtual environment ...
    (@venv) path-to $
```

## Pimp and West

In combination with the `west` tool, `pimp` can be used to install version
controlled tools (versions are managed by `west`) in the virtual environment's
binary folder, thus, making them accessible as long as the virtual environment
is activated.

if a `.west` directory is found in the current environment while command
`. pimp` is invoked, `pimp` will automatically install the `west` Python
package in the virtual environment. The following sequence is typical for the
creation of `west` workspaces with virtual tool support (with tools only
available during activation of the virtual environment).

```
    $ pimp --init @my-ws   # init .pimp for my workspace (@my-ws)
    $ mkdir .west          # want also have west installed
    $ . pimp               # build/setup/activate @my-ws and install west
```


## Pimp and West

`west` can be used in general for workspaces which are not related to Zephyr, but
most `west` applications are related to Zephyr. One specific use case of pimp is
to modify a virtual environment of a west workspace containing the zephyr tree.
A specific task is to set the environment variable `ZEPHYR_BASE`, when the
virtual environment is activated, and to unset in the deactivation case
(setting ZEPHYR_BASE is vital for bilding freestanding applications). In such
use case the pimp can automatically prepare proper `setup`/`cleanup` scripts.

```
    #!/bin/bash
    # setup (setup script for virtual environment)

    echo '=== setup virtual environment ...'
    export ZEPHYR_BASE=/path-to/zephyr
```

```
		#!/bin/bash
		# cleanup (cleanup script for virtual environment)

		echo '=== cleanup virtual environment ...'
		unset ZEPHYR_BASE
```

Pimp has a special feature (option `--zephyr`) to pimp a virtual environment
of a west/zephyr workspace which is demonstrated in the following example,
showcasing installation of Zephyr version 3.6.0

```
    ... $ mkdir z3.5.0; cd z3.5.0
    z3.5.0 $ pimp --init @z3.5.0              # init .pimp with setup/cleanup scripts
    z3.5.0 $ pimp --zephyr                    # extend setup/cleanup for zephyr
    z3.5.0 $ . pimp                           # create/pimp/activate virtual environment
    (@z3.5.0) z3.5.0 $ pip install west       # install west (Python) package in @z3.5.0
    (@z3.5.0) z3.5.0 $ west init -mr v3.5.0   # init for specific version
    (@z3.6.0) z3.6.0 $ west update            # update zephyr installation
```



## Pre-Requisites

Pre-requisites for `pimp` is a `bash` environment (as supported by Linux,
Mac-OS and Windows/WSL) with `python` and `pip` running. At the time of writing
`pimp` was tested on a Mac computer with the following installation:

```
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

```
    $ git clone https://github.com/bluccino/tools-pimp  # see tools-pimp/bin/pimp
```


# Tutorial

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

```
    ... $ mkdir path-to/my-ws    # create folder
    ... $ cd path-to/my-ws       # change directory to my-ws
    my-ws $ python3 -m venv @my-ws
```

Note that the virtual environment at this time is not activated. So far we got
the following file tree:

```
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

```
    my-ws $ source @my-ws/bin/activate  # script must be sourced for activation
    (@my-ws) my-ws $ deactivate         # undo environment modifications
    my-ws $
```

## Creation of Scripts `setup` and `cleanup`

In a first step we will create a hidden `.pimp` folder where all stuff that
`pimp` needs will be located. Next we create a `.pimp/bin` folder to contain all
scripts which `pimp` should install into `@my-ws/bin`.

```
    mkdir .pimp       # a hidden folder with all stuff that pimp needs
    mkdir .pimp/bin   # for binaries which should be installed in @my-ws/bin
```

The `setup` script echos the message 'hello, @my-ws' and defines alias `al`.

```
    my-ws $ echo "echo 'hello, @my-ws'" >.pimp/bin/setup
    my-ws $ echo "alias la='ls -a'" >>.pimp/bin/setup  # append
```

The plan is to source `setup` during activation, thus, for testing we also need
to source.

```
    my-ws $ cat .pimp/bin/setup    # let's see the content of script setup
    echo 'hello, @my-ws'
    alias la='ls -a'
    my-ws $ source .pimp/bin/setup  # test script setup (we need to source)
    hello, @my-ws
    my-ws $ la  # test alias
    .	..	.pimp	@my-ws
```

That works well! Let's create script `cleanup`.

```
    my-ws $ echo "echo 'good bye, @my-ws'" >.pimp/bin/cleanup
    my-ws $ echo "unalias la" >>.pimp/bin/cleanup  # append
```

For similar reasons we need to source `cleanup` for testing. When we invoke
alias `la` after sourcing `cleanup` we expect that `bash` reports an error,
since the alias should be removed.

```
    my-ws $ cat .pimp/bin/cleanup    # let's see the content of cleanup
    echo 'good bye, @my-ws'
    unalias la
    my-ws $ source .pimp/bin/cleanup  # test script cleanup (we need to source)
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
            source setup/cleanup upon activation/deactivation of @my-ws
~~~

How does `@my-ws/bin/activate` know where `setup` and `cleanup` are located?
In `.pimp/bin` ? The answer is no! The scripts are expected to be in the virtual
environment's binary directory `@my-ws/bin`. If one of them is missing, it is
also OK and no error is reported.

The first action (pimping the `activate` script) is achieved by the following
command line:

```
    my-ws $ pimp @my-ws   # pimp @my-ws/bin/activate script
```

Since `activate` defines also the `deactivate` function, this command pimps
also `deactivate` in order to source the `@my-env/bin/cleanup` script, which is
ignored wthout error report if missing. All in all we require pimp to do also
the second action.

~~~
    Step 2: We need to install (copy) our prepared scripts setup and cleanup
            in the virtual environment's binary folder
~~~

This is done by

```
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
the copies of `setup` and `cleanup`.

```
    my-ws $  tv \@my-ws/bin
    @my-ws/bin
    ├── activate
    :       :
    ├── setup
    └── cleanup

    1 directory, 12 files
```

Then we activate the virtual environment, cross check the 'hello message' and
verify that alias `la` is working.

```
    my-ws $ source @my-ws/bin/activate
    hello, @my-ws
    (@my-ws) my-ws $ la   # test alias
    .	..	.pimp	@my-ws
```

Finally we test deactivation and expect `bash` to issue an error message when we
invoke alias `la`.

```
    (@my-ws) my-ws $ deactivate
    good bye, @my-ws
    my-ws $ la   # test alias
    -bash: la: command not found
```

# Conclusions

* `pimp` is a `bash` based script, arranging execution of a custom `setup`
  script at the end of the activation of a virtual environment
* `pimp` also arranges execution of a custom `cleanup` script at the begin of
  deactivation of a virtual environment.
* `pimp` does this by modifying the `bin/activate` script of a virtual
  environment
* `pimp`can optionally also consulted for installation of some prepared binaries
  in a virtual environment's binary folder
* there is a simple curl-formula for downloading the `pimp` script, which can
  subsequently be copied into a binary folder of choice.
