# Stolen and modified from
# https://github.com/Hi-Angel/dotfiles/blob/0b9418224e4ce7c9783dbc2d9473fd1991b9b0b2/.zshrc#L148-L160.
#
# See thread
# https://lore.kernel.org/git/eda317b080a2e75a170c051c339a76115cce5ad7.camel@yandex.ru/

# rebase-at <action> <comit-ids-and-co>
function rebase-at() {
    local action=$1
    shift 1
    GIT_EDITOR='perl -MFile::Basename=basename -wE '"'"'
        my $f = shift;
	exec qw[sed -i -E], q[1s/\\w+/'$action'/], $f
	    if basename($f) eq q[git-rebase-todo];
        exec "$ENV{EDITOR} $f";
    '"'" git rebase -i "$@"
}
