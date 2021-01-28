source ~/.bashrc

declare _PROFILE
for _PROFILE in \
  "${HGI_RC}/farm/${HGI_FARM}" \
  "${HGI_RC}/host/${HOSTNAME}" \
  "${HGI_RC}/user/${HGI_USER}"
do [[ -e "${_PROFILE}/profile" ]] && source "${_PROFILE}/profile"; done
unset _PROFILE
