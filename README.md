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

## To Do

- [ ] Install `ldapvi` on `farm5` and port
      [`humgen_grp`](host/hgi-mercury-farm3/bin/humgen_grp).

- [ ] Install [Lustre Operator](https://github.com/wtsi-hgi/lustre_operator)
      on `farm5` and port its [wrappers](farm/farm3/rc/02-lustre_operator).
