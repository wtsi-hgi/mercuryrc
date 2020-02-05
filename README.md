# Universal Mercury `.bashrc`

This is `mercury`'s `.bashrc`, which is universal in the sense that it
sources and adds to the `PATH` scripts that are farm, host or user
specific (in increasing order of precedence):

* Farm-based scripts go in `farm/${FARM}`;
* Host-based scripts go in `host/${HOSTNAME}`;
* User-based scripts got in `user/${SUDO_USER}` (i.e., the user who
  `sudo`'d as `mercury`)

Within these directories there should be an `rc` directory and a `bin`
directory. The latter will be prepended to the `PATH`, the former will
be iterated through and each script therein will be sourced in numerical
order.

**Note** If you log in directly as `mercury` (i.e., without `sudo`'ing),
then your user scripts won't be sourced. This can be done manually by
running `hgi-user ${USERNAME}`.

The following environment variables will be available upon completion:

* `HGI_RC` is the directory in which the Universal `.bashrc` resides;
* `HGI_USER` is the user from which you `sudo`'d, if applicable (`NONE`,
  otherwise);
* `HGI_FARM` is the LSF farm you are currently using, if applicable
  (`NONE`, otherwise).

## To Do

- [ ] Install `ldapvi` on `farm5` and port
      [`humgen_grp`](host/hgi-mercury-farm3/bin/humgen_grp).

- [ ] Install [Lustre Operator](https://github.com/wtsi-hgi/lustre_operator)
      on `farm5` and port its [wrappers](farm/farm3/rc/02-lustre_operator).
