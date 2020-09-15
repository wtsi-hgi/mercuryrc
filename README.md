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
order.

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
