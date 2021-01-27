source ~/.bashrc

# Disable rm in interactive sessions
rm() {
  >&2 echo "$(tput setaf 1)rm is disabled$(tput sgr0)"
  >&2 echo "Enter the armed environment, with 'arm' to enable"
  return 1
}
