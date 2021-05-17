# Undo Debian's dumbing down of "man".  See
# https://lore.kernel.org/git/60a046bd83001_f4b0f20861@natae.notmuch/

man() {
	GROFF_NO_SGR=1 \
	LESS_TERMCAP_md=$'\e[1;31m' \
	LESS_TERMCAP_me=$'\e[0m' \
	LESS_TERMCAP_us=$'\e[1;34m' \
	LESS_TERMCAP_ue=$'\e[0m' \
	LESS_TERMCAP_so=$'\e[1;35m' \
	LESS_TERMCAP_se=$'\e[0m' \
	command man "$@"
}
