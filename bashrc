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

# Source user, host and farm-specific RC files
declare _RC_ROOT="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
declare _RC_DIR
declare _RC

declare HGI_USER="NONE"
if [[ -n "${SUDO_USER}" ]]; then
  HGI_USER="${SUDO_USER}"
fi

declare HGI_FARM="NONE"
if command -v lsclusters >/dev/null; then
  HGI_FARM="$(lsclusters | awk 'NR == 2 { print $1 }')"
  export LSB_DEFAULTGROUP="mercury-grp"
fi

for _RC_DIR in "${_RC_ROOT}/farm/${HGI_FARM}" \
             "${_RC_ROOT}/host/${HOSTNAME}" \
             "${_RC_ROOT}/user/${HGI_USER}"
do
  if [[ -d "${_RC_DIR}" ]]; then
    while read -r _RC; do
      source "${_RC}"
    done < <(find "${_RC_DIR}/rc" -type f | sort -n)
    export PATH="${_RC_DIR}/bin:${PATH}"
  fi
done

unset _RC
unset _RC_DIR
unset _RC_ROOT

export HGI_USER
export HGI_FARM
