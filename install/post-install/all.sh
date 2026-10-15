run_logged $OMARCHY_INSTALL/post-install/pacman.sh
run_logged $OMARCHY_INSTALL/post-install/apply-choices.sh
source $OMARCHY_INSTALL/post-install/allow-reboot.sh
source $OMARCHY_INSTALL/post-install/finished.sh
