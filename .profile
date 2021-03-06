_addpath() {
    _varname=$1; shift
    for _dir in "$@"; do
        if [[ -d "$_dir" ]]; then
            read -r -d '' _eval <<EOF
if [[ -z "\${${_varname}}" ]]; then
    ${_varname}="${_dir}:"
elif [[ ! "\${${_varname}}" =~ "(^|:)${_dir}(:|$)" ]]; then
    ${_varname}="\${${_varname}%%:}:${_dir}"
fi
EOF
            eval "${_eval}"
        fi
    done
}

_prependpath() {
    _varname=$1; shift
    for _dir in "$@"; do
        if [[ -d "$_dir" ]]; then
            read -r -d '' _eval <<EOF
if [[ -z "\${${_varname}}" ]]; then
    ${_varname}="${_dir}:"
else
    ${_varname}="\${${_varname}/":\${_dir}"/}"
    ${_varname}="${_dir}:\${${_varname}/"\${_dir}:"/}"
fi
EOF
            eval "${_eval}"
        fi
    done
}

if [[ -f $HOME/.system_profile ]]
then
    . $HOME/.system_profile
fi

_prependpath PATH /usr/local/sbin /usr/local/bin

_prependpath PATH /usr/lib/distcc/bin /usr/lib64/distcc/bin

if [[ -d /usr/lib/ccache/bin ]]; then
    _prependpath PATH /usr/lib/ccache/bin
elif [[ -d /usr/lib/ccache ]]; then
    _prependpath PATH /usr/lib/ccache
elif [[ -d /usr/lib64/ccache/bin ]]; then
    _prependpath PATH /usr/lib64/ccache/bin
elif [[ -d /usr/lib64/ccache ]]; then
    _prependpath PATH /usr/lib64/ccache
fi
if which distcc >/dev/null 2>/dev/null; then
    CCACHE_PREFIX="distcc"
fi
if [[ -d /ssd/.ccache ]]; then
    CCACHE_DIR=/ssd/.ccache
fi

_prependpath PATH $HOME/.rvm/bin

if [ -d $HOME/local/plan9 ]
then
    PLAN9=$HOME/local/plan9
    export PLAN9
    _addpath PATH $PLAN9/bin
    _addpath MANPATH $PLAN9/man
fi

_prependpath PATH $HOME/local/sbin $HOME/local/bin
_prependpath INFOPATH /usr/local/share/info $HOME/local/share/info
_prependpath MANPATH /usr/local/share/man $HOME/local/share/man
_prependpath PKG_CONFIG_PATH /usr/local/lib/pkgconfig $HOME/local/lib/pkgconfig

GOPATH=$HOME/go
_prependpath PATH $GOPATH/bin

_prependpath PYTHONPATH $HOME/local/lib64/python
_prependpath PYTHONPATH $HOME/local/lib/python2.7/site-packages

if [ -f $HOME/local/.profile ]
then
    # for packages underneath ~/local/
    . $HOME/local/.profile
fi

if [ -f $HOME/.local/.profile ]
then
    # for local settings
    . $HOME/.local/.profile
fi

_prependpath PATH $HOME/bin

EDITOR=emacsclient
ALTERNATE_EDITOR="vim"

export PATH CPATH PKG_CONFIG_PATH INFOPATH MANPATH PYTHONPATH EDITOR ALTERNATE_EDITOR
export GOPATH
export CCACHE_PREFIX CCACHE_DIR

# colorize ls, less, grep
CLICOLOR=on
LESS="-R"
GREP_COLOR=auto
export CLICOLOR GREP_COLOR LESS

# move chromium cache to tmpfs
if [ -f /etc/chromium/default ]; then
    . /etc/chromium/default
    CHROMIUM_USER_FLAGS=" --disk-cache-dir=/tmp/chromium-cache-leif ${CHROMIUM_FLAGS}"
    export CHROMIUM_USER_FLAGS
fi

if [ -f $HOME/.shell_utils ]; then
    . $HOME/.shell_utils
fi

# Enable gpg-agent if it is not running
GPG_AGENT_SOCKET="${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh"
if [ ! -S $GPG_AGENT_SOCKET ]; then
    gpg-agent --daemon >/dev/null 2>&1
    export GPG_TTY=$(tty)
fi

# Set SSH to use gpg-agent if it is configured to do so
GNUPGCONFIG=${GNUPGHOME:-"$HOME/.gnupg/gpg-agent.conf"}
if grep -q enable-ssh-support "$GNUPGCONFIG"; then
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK=$GPG_AGENT_SOCKET
fi

if which ssh-add >/dev/null 2>/dev/null && [ ! -z "$SSH_AGENT_PID" ] && ps ax | grep "$SSH_AGENT_PID" | grep -q -v grep; then
    if ! ssh-add -l | grep -q .ssh/id_rsa; then
        ssh-add
    fi
fi

if [[ -f "$HOME/perl5/perlbrew/etc/bashrc" ]]; then
    . "$HOME/perl5/perlbrew/etc/bashrc"
fi

export PATH="$HOME/.cargo/bin:$PATH"
