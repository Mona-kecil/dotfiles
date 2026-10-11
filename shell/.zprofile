# macOS /etc/zprofile runs path_helper after .zshenv. Restore our order.
source "${ZDOTDIR:-$HOME}/.zshenv"
