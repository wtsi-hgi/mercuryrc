# Universal Mercury `.bashrc`

This is `mercury`'s `.bashrc`, which is universal in the sense that it
sources and adds to the `PATH` scripts that are farm, host or user
specific (in increasing order of precedence):

* Farm-based scripts go in `farm/${FARM}`;
* Host-based scripts go in `host/${HOSTNAME}`;
* User-based scripts go in `user/${USERNAME}`.

Within these directories there should be an `rc` directory and a `bin`
directory. The latter will be prepended to the `PATH`, the former will
be iterated through and each script therein will be sourced in numerical
order. A `profile` file may also be placed in these directories, which
will be sourced in interactive environments.

The `bashrc` and `profile` files in the root of this repository must be
symlinked to `~/.bashrc` and `~/.profile` (or `~/.bash_profile`),
respectively. Be wary of any process that magically updates the
`.bashrc` on your behalf (e.g., Conda); such changes should not be
committed.

**Note** If you `sudo` as `mercury`, then your user scripts will be
sourced automatically. However, if you log in directly as `mercury`
(i.e., without `sudo`'ing), then your user scripts won't be sourced.
This can be done manually by running `hgi-user ${USERNAME}`, or by
sending the `LC_HGI_USER` environment variable in your SSH session:

    ssh -o SendEnv=LC_HGI_USER mercury@some_host

The following environment variables will be available upon completion:

* `HGI_RC` is the directory in which the Universal `.bashrc` resides;
* `HGI_USER` is the user from which you `sudo`'d or set via
  `LC_HGI_USER`, if applicable (`NONE`, otherwise);
* `HGI_FARM` is the LSF farm you are currently using, if applicable
  (`NONE`, otherwise).

## farm5 Armed Environment

In the normal mercury Bash environment, on farm5 machines, the following
restrictions are made:

* `set -o noclobber` will prevent redirecting output into a file that
  already exists.
* `rm` will be completely disabled and instead show an error message.
* The `--remove-files` option to `tar` will be stripped out and a
  warning message will be shown.
* The `-delete` and `-exec rm` options to `find` will be forbidden and
  instead show an error message.
* An `rm` argument to `xargs` will be forbidden and instead show an
  error message.

An "armed environment" is available using the `arm` command. This
environment is intended only for performing data management tasks and
should not be for general use; upon entering, the user will be told as
such in no uncertain terms. The entire session will be logged to disk.

The armed environment will lift the following restrictions from above:

* `rm` will now be active and will automatically set the `-I` and `-v`
  flags, for interactive deletion (when deleting more than 3 files) and
  verbosity, respectively.

The armed environment will impose additional restrictions and
safeguards:

* The environment will refuse to work if the user who logged in as
  mercury cannot be established.
* The environment will refuse to work outside the hours of 9am to 4pm
  (this can be overridden with the `--yes-i-know-its-late` option).
* The prompt will show the full path of the current working directory.
* `set -f` will prevent glob expansion.
* `set -u` will raise an error on undeclared variables.
* `set -B` will prevent brace expansion.

**Note** While the above safety measures can be circumvented relatively
easily, this setup is designed to be seamless enough that doing so would
be more trouble than it's worth. The armed environment is imposed on
`mercury` users as a matter of [policy](https://confluence.sanger.ac.uk/display/HGI/Data+Management+Policy).
