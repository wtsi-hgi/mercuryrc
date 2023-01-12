# Universal Mercury .bashrc
# Christopher Harrison <ch12@sanger.ac.uk>

# Prevent file clobbering with redirection
set -C

# History keeping
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Proxying
export http_proxy="http://wwwcache.sanger.ac.uk:3128"
export HTTP_PROXY="${http_proxy}"
export https_proxy="${http_proxy}"
export HTTPS_PROXY="${http_proxy}"
export no_proxy=localhost,127.0.0.1,.internal.sanger.ac.uk

# Prompt
_hgi_group() {
  local group="$(groups | cut -d" " -f1)"
  [[ "${group}" = "hgi" ]] || printf ":%s" "${group}"
}

_hgi_abbreviate_pwd() {
  local pwd="$1"

  echo "${pwd}" \
  | awk -v LIMIT="${HGI_ABBREVIATE_LIMIT-2}" '
    BEGIN { FS = OFS = "/" }

    { fields = NF }
    $1 == "" { fields-- }

    LIMIT == 0 || fields <= LIMIT { print $0 }
    LIMIT >  0 && fields >  LIMIT {
      printf("...")
      for (i = NF - LIMIT; i < NF; i++)
        printf("%s%s", OFS, $(i + 1))
    }
  '
}

export PS1='\u$(_hgi_group)@\h $(_hgi_abbreviate_pwd "\w")$ '

# Editor
export EDITOR="vim"

# Aliases
alias sort="LC_ALL=C sort"

# What user are we?
readonly HGI_USER="${SUDO_USER-${LC_HGI_USER-NONE}}"
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

  # Prepend to PATH
  [[ -d "${directory}/bin" ]] && export PATH="${directory}/bin:${PATH}"

  # Source
  # n.b., We duplicate stdin to FD 3 and pass that in to the source's
  # stdin; this avoids the blocking of our stdin that read consumes
  local _rc
  exec 3<&0
  while read -r _rc; do
    source "${_rc}" <&3
  done < <(find "${directory}/rc" -type f -o -type l 2>/dev/null | sort -n)
  exec 3<&-
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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/software/hgi/installs/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/software/hgi/installs/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/software/hgi/installs/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/software/hgi/installs/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

