export PATH=/software/singularity-v3.4.2/bin:$PATH

if [[ $HOSTNAME == "hgi-www" ]]; then
    LOCALDIR=/nfs/hgi01/local-hgi-www
elif [[ $HOSTNAME == "hgi-www-dev" ]]; then
    LOCALDIR=/nfs/hgi01/local-hgi-www
elif [[ $HOSTNAME == "hgi-mercury" ]]; then
    LOCALDIR=/nfs/hgi01/local-hgi-mercury
elif [[ $HOSTNAME =~ farm4.* ]] || [[ $HOSTNAME =~ rhel7.* ]]; then
	true
else
  export R_LIBS=$HOME/r_libs
  export http_proxy=http://wwwcache.sanger.ac.uk:3128
  export HTTP_PROXY=http://wwwcache.sanger.ac.uk:3128
  export HTTPS_PROXY="https://wwwcache.sanger.ac.uk:3128"
  export PERL_INLINE_DIRECTORY=~/.Inline

  if [ -e /usr/local/lsf/conf/lsf.cluster.farm2 ]; then 
    # perl stuff
    export LD_LIBRARY_PATH=/software/perl-5.16.0/bin:$LD_LIBRARY_PATH
    # setup perl runtime path
    export PATH=/software/perl-5.16.0/bin:$PATH
    eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)
  else
    OS=$(lsb_release -cs)
    MACH=$(uname -m)
    OSMACH=${OS}-${MACH}
    LOCALDIR=${HOME}/local-${OSMACH}

    export PATH=/software/perl-5.18.1/bin:$LOCALDIR/bin:$PATH
    export PKG_CONFIG_PATH=$LOCALDIR/lib/pkgconfig:$PKG_CONFIG_PATH
    export LD_LIBRARY_PATH=/software/perl-5.18.1/bin:$LOCALDIR/lib:$LD_LIBRARY_PATH
    eval $(perl -I$LOCALDIR/lib/perl5 -Mlocal::lib=$LOCALDIR)
  fi

  #override stuff from perl bin with local if necessary
  export PATH=$HOME/local/bin:$PATH
  #python
  export PYTHONPATH=$LOCALDIR/lib/python2.7/site-packages:$PYTHONPATH

  #project
  export LSB_DEFAULTGROUP=mercury-grp
  #tools
  export PICARD=/nfs/users/nfs_m/mercury/src/picard-tools-latest
  export GATK=/nfs/users/nfs_m/mercury/src/GenomeAnalysisTK-2.7

  # required for VRPipe
  export SAMTOOLS=/nfs/users/nfs_m/mercury/src/samtools-0.1.19
  export HTSLIB=/software/hgi/pkglocal/htslib-git-1.2.1-11-ge5a0124
  export CRAMTOOLS=/nfs/users/nfs_m/mercury/local-precise-x86_64/bin/cramtools-2.1.jar

  # warehouse 
  export WAREHOUSE_DATABASE="sequencescape_warehouse"
  export WAREHOUSE_HOST="seqw-db.internal.sanger.ac.uk"
  export WAREHOUSE_PORT="3379"
  export WAREHOUSE_USER="warehouse_ro"

  #vrtrack
  export VRTRACK_HOST=hgivrp-db
  export VRTRACK_PORT=3400
  export VRTRACK_RO_USER=hgipro
  export VRTRACK_RW_USER=hgiprw
  export VRTRACK_PASSWORD=REDACTED

  #kerberos for farm
  export KRB5CCNAME=/nfs/users/nfs_m/mercury/.krb5ccache/credentials

  #editor
  export EDITOR=vim

  . /software/hgi/etc/profile.hgi
  module load hgi/ldapvi/latest
  module load hgi/hgquota/latest
  module load hgi/teepot/latest

  alias emacs="emacs -nw"

  if [ -n "$SUDO_USER" ]; then
    export SUDO_HOME="$(getent passwd $SUDO_USER | cut -d: -f6)"

    # Use personal Vim dotfiles, if they're available
    if [[ -e "$SUDO_HOME/.vimrc" ]] && [[ -d "$SUDO_HOME/.vim" ]]; then
      module add hgi/vim/latest
      alias vim="vim -u \"$SUDO_HOME/.vimrc\" --cmd \"set rtp^=$SUDO_HOME/.vim\""
    fi
  fi

  # History keeping
  export HISTSIZE=50000
  export HISTFILESIZE=50000
  export HISTCONTROL=ignoredups:erasedups
  shopt -s histappend 

  # Hahahahaaaaa :)
  _fun_times() {
    # April 1st
    if [[ "$(date +%d%m)" == "0104" ]]; then
      return 0
    fi

    # Friday afternoons
    if (( $(date +%w) == 5 )) && (( $(date +%k) >= 12 )); then
      return 0
    fi

    return 1
  }

#  if [[ -d "/software/hgi/pkglocal" ]] && _fun_times; then
#    module load hgi/ruby/latest
#    export GEM_PATH="$(echo ~mercury/lolcat):${GEM_PATH}"
#    alias cat="$(echo ~mercury/checkouts/lolcat/bin/lolcat)"
#  fi

  # Pointless alias is pointless...
  alias sudo="sudo "

  LOP="/software/lustre_operator/bin/lustre_operator /usr/bin/lfs"

  alias lop111="${LOP} /lustre/scratch111"
  alias lop113="${LOP} /lustre/scratch113"
  alias lop114="${LOP} /lustre/scratch114"
  alias lop115="${LOP} /lustre/scratch115"
  alias lop116="${LOP} /lustre/scratch116"
  alias lop117="${LOP} /lustre/scratch117"
  alias lop118="${LOP} /lustre/scratch118"

  alias slop111="sudo ${LOP} /lustre/scratch111"
  alias slop113="sudo ${LOP} /lustre/scratch113"
  alias slop114="sudo ${LOP} /lustre/scratch114"
  alias slop115="sudo ${LOP} /lustre/scratch115"
  alias slop116="sudo ${LOP} /lustre/scratch116"
  alias slop117="sudo ${LOP} /lustre/scratch117"
  alias slop118="sudo ${LOP} /lustre/scratch118"

  lustre_quota() {
    # Simple wrapper over lustre_operator getquota, for less typing
    local scratch="$1"
    local other_args=${@:2}

    local -a lop_columns=("type" "name" "size-used" "size-hardlimit" "size-remaining" "inode-used" "inode-hardlimit" "inode-remaining")
    local -a lop_groups
    local -a lop_users
    local -a lop_arguments

    for arg in ${other_args}; do
      if [ "${arg:0:1}" = "-" ]; then
        lop_arguments+=("$arg")
      else
        if getent group "${arg}" > /dev/null 2>&1; then
          lop_groups+=("${arg}")
        elif id "${arg}" > /dev/null 2>&1; then
          lop_users+=("${arg}")
        else
          lop_arguments+=("$arg")
        fi
      fi
    done

    sudo ${LOP} /lustre/scratch${scratch} getquota ${lop_columns[@]/#/-c } \
                                                   ${lop_groups[@]/#/-g } \
                                                   ${lop_users[@]/#/-u } \
                                                   ${lop_arguments} \
    | column -t
  }
  
  # Convenient aliases with base-1000 quantification
  alias gq111="lustre_quota 111 -d"
  alias gq113="lustre_quota 113 -d"
  alias gq114="lustre_quota 114 -d"
  alias gq115="lustre_quota 115 -d"

  humgen_grp() {
    local cmd="$1"
    local grp="$2"

    _stderr() {
      local message="$*"

      if [[ -t 2 ]]; then
        message="\033[0;31m${message}\033[0m"
      fi

      >&2 echo -e "${message}"
    }

    # Sanity check arguments
    case "${cmd}" in
      "edit" | "member" | "owner")
        # Check group exists
        if ! getent group "${grp}" >/dev/null 2>&1; then
          _stderr "No such group \""${grp}"\"!"
          return 1
        fi

        # Check mercury is an owner (and exit if we want to edit)
        if (( !$(ldapsearch -xLLL "(&(owner=uid=mercury,ou=people,dc=sanger,dc=ac,dc=uk)(&(objectClass=posixGroup)(cn=${grp})))" | wc -l) )); then
          _stderr "Not a humgen group (probably); mercury is not an owner of the \"${grp}\" group!"
          if [[ "${cmd}" = "edit" ]]; then return 1; fi
        fi
        ;;

      *)
        _stderr "humgen_grp edit|member|owner GROUP_NAME"
        return 1
        ;;
    esac

    _group_search() {
      # LDAP search string for groups
      local grp="$1"
      echo "(&(objectClass=posixGroup)(cn=${grp}))"
    }

    _ldap_group() {
      # Get LDAP entry of group
      local grp="$1"
      local -a attrs=("${@:2}")
      ldapsearch -xLLL "$(_group_search "${grp}")" ${attrs[@]}
    }

    _pretty_print() {
      # Pretty print a list of uid-cn tuples
      awk -F": " '$1 == "uid" { uid = $2 }
                  $1 == "cn"  { cn  = $2 }
                  cn && uid   { print cn " (" uid ")"; uid = cn = "" }'
    }

    case "${cmd}" in
      "edit")
        # Edit LDAP group
        module add hgi/ldapvi/latest
        ldapvi "$(_group_search "${grp}")"
        ;;

      "owner")
        # Pretty-print owners from LDAP
        _ldap_group "${grp}" owner \
        | awk -F": " '$1 == "owner" { print $2 }' \
        | xargs -n1 -I{} ldapsearch -xLLL -s base -b "{}" uid cn \
        | _pretty_print
        ;;

      "member")
        # Pretty-print members from LDAP and default groups, with a
        # warning for those who are not in the LDAP group

        _pretty_print_each_ldap_person() {
          xargs -n1 -I{} ldapsearch -xLLL -s one -b "ou=people,dc=sanger,dc=ac,dc=uk" "(uid={})" uid cn \
          | _pretty_print \
          | sort
        }

        _members_by_default_group() {
          local grp="$1"
          local gid="$(getent group "${grp}" | cut -d: -f3)"

          getent passwd \
          | awk -F: -v GID="${gid}" '$4 == GID { print $1 }' \
          | _pretty_print_each_ldap_person
        }

        _members_by_ldap() {
          local grp="$1"

          _ldap_group "${grp}" memberUid \
          | awk -F: '$1 == "memberUid" { print $2 }' \
          | _pretty_print_each_ldap_person
        }

        comm --output-delimiter="|" <(_members_by_ldap "${grp}") <(_members_by_default_group "${grp}") \
        | awk -F"|" 'BEGIN   { out_of_sync = 0 }
                     NF == 1 { print $1 }
                     NF == 2 { out_of_sync = 1; print $2 " *" }
                     NF == 3 { print $3 }
                     END     { if (out_of_sync) print "(*) These users are not members of the LDAP group!" }'
        ;;
    esac
  }

  export GOPATH=$(echo ~/go)
  export ANSIBLE_CONFIG=/nfs/humgen01/teams/hgi/conf/ansible/ansible.cfg
fi

#set bash prompt
PS1='\u@\h:\w\$ '

# do not use HTTP proxy on hgs4 cluster
if [[ $HOSTNAME == +(hgs4*) ]]; then
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
fi

export ARVADOS_API_TOKEN=989wbpxzulsfrs3utbv0ukj7dctqd3idthvl8aykqjd33hqs1
export ARVADOS_API_HOST=api.arvados.sanger.ac.uk

function pathperms { 
  path=$1
  echo "Reporting ownership and permissions on all path components of ${path}"
  pathcomps=$(echo "${path}" | awk 'BEGIN {RS="/"; path="";} NR!=1 {path=path"/"$1; print path;}')
  for pathcomp in ${pathcomps}; do 
    stat -c "%U %G %A" ${pathcomp}
  done | column -t
}

export OS_USERNAME=mercury
#if [[ -r /home/mercury/openstack-delta-mercury.pw ]]; then
#    export OS_PASSWORD=$(cat /home/mercury/openstack-delta-mercury.pw)
#fi
#export OS_AUTH_URL=http://172.27.66.32:5000/v2.0
if [[ -r /home/mercury/openstack-zeta-mercury.pw ]]; then
    export OS_PASSWORD=$(cat /home/mercury/openstack-zeta-mercury.pw)
fi
export OS_AUTH_URL=https://zeta.internal.sanger.ac.uk:13000

source $(pwd)/checkouts/git-subrepo/.rc
# . /nfs/cellgeni/miniconda3/etc/profile.d/conda.sh  # commented out by conda initialize

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

# . /lustre/scratch116/casm/team113/vvi/scratch/miniconda3/etc/profile.d/conda.sh
# . /lustre/scratch116/casm/team113/vvi/scratch/miniconda3/etc/profile.d/conda.sh  # commented out by conda initialize
# . /lustre/scratch116/casm/team113/vvi/scratch/miniconda3/etc/profile.d/conda.sh  # commented out by conda initialize
# . /lustre/scratch116/casm/team113/vvi/scratch/miniconda3/etc/profile.d/conda.sh  # commented out by conda initialize
