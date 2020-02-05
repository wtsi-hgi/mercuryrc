# Universal Mercury .bashrc
# Christopher Harrison <ch12@sanger.ac.uk>

# History keeping
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Proxying
declare _PROXY="wwwcache.sanger.ac.uk:3128"
export http_proxy="http://${_PROXY}"
export HTTP_PROXY="${http_proxy}"
export https_proxy="https://${_PROXY}"
export HTTPS_PROXY="${https_proxy}"
unset _PROXY

# Prompt
export PS1="\u@\h:\w\$ "

# Editor
export EDITOR="vim"

# What user are we?
declare HGI_USER="NONE"
if [[ -n "${SUDO_USER}" ]]; then
  HGI_USER="${SUDO_USER}"
fi

export HGI_USER

# What farm are we on?
declare HGI_FARM="NONE"
if command -v lsclusters >/dev/null; then
  HGI_FARM="$(lsclusters | awk 'NR == 2 { print $1 }')"

  # Default farm environment variables
  export LSB_DEFAULTGROUP="mercury-grp"
  export KRB5CCNAME="$(echo ~mercury/.krb5ccache/credentials)"
fi

export HGI_FARM

# Where is the universal .bashrc?
export HGI_RC="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# Source user, host and farm-specific RC files
_hgi_source() {
  local directory="$1"
  [[ -d "${directory}" ]] || return

  # Source
  local _rc
  while read -r _rc; do
    source "${_rc}"
  done < <(find "${directory}/rc" -type f 2>/dev/null | sort -n)

  # Prepend to PATH
  [[ -d "${directory}/bin" ]] && export PATH="${directory}/bin:${PATH}"
}

# Convenience function for sourcing user scripts
hgi-user() {
  local user="$1"
  _hgi_source "${HGI_RC}/user/${user}"
}

declare _RC_DIR
for _RC_DIR in \
  "${HGI_RC}/farm/${HGI_FARM}" \
  "${HGI_RC}/host/${HOSTNAME}" \
  "${HGI_RC}/user/${HGI_USER}"
do _hgi_source "${_RC_DIR}"; done
unset _RC_DIR
