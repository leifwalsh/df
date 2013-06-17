if [[ -f $HOME/.system_profile ]]
then
    . $HOME/.system_profile
fi

# add xcode 4.4 developer path
tcpath=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr
if [[ -d $tcpath ]]
then
    PATH=$PATH:$tcpath/bin
    MANPATH=$MANPATH:$tcpath/share/man
fi
platpath=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/usr
if [[ -d $platpath ]]
then
    #PATH=$PATH:$platpath/bin
    CPATH=$CPATH:$platpath/include
fi
devpath=/Applications/Xcode.app/Contents/Developer/usr
if [[ -d $devpath ]]
then
    PATH=$PATH:$devpath/bin
    MANPATH=$MANPATH:$devpath/share/man
fi

PATH=/usr/local/bin:/usr/local/sbin:$PATH

if [[ -d /usr/lib/distcc/bin ]]; then
    PATH=/usr/lib/distcc/bin:$PATH
elif [[ -d /usr/lib64/distcc/bin ]]; then
    PATH=/usr/lib64/distcc/bin:$PATH
fi
if [[ -d /usr/lib/ccache/bin ]]; then
    PATH=/usr/lib/ccache/bin:$PATH
elif [[ -d /usr/lib/ccache ]]; then
    PATH=/usr/lib/ccache:$PATH
elif [[ -d /usr/lib64/ccache/bin ]]; then
    PATH=/usr/lib64/ccache/bin:$PATH
elif [[ -d /usr/lib64/ccache ]]; then
    PATH=/usr/lib64/ccache:$PATH
fi
if which distcc >/dev/null 2>/dev/null; then
    CCACHE_PREFIX="distcc"
fi
if [[ -d $HOME/.rvm/bin ]]; then
    PATH=$HOME/.rvm/bin:$PATH
fi
if [ -d /Library/Frameworks/Python.Framework/Versions/Current/bin ]; then
    PATH=/Library/Frameworks/Python.Framework/Versions/Current/bin:$PATH
fi

# add coreutils
if which brew >/dev/null 2>/dev/null && [ -d $(brew --prefix coreutils)/libexec/gnubin ]; then
    PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
fi

if [ -d $HOME/local/plan9 ]
then
    PLAN9=$HOME/local/plan9
    export PLAN9
    PATH=$PATH:$PLAN9/bin
    MANPATH=$MANPATH:$PLAN9/man
fi

PATH=$HOME/local/bin:$HOME/local/sbin:$PATH
PKG_CONFIG_PATH=$HOME/local/lib/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
INFOPATH=$HOME/local/share/info:/usr/local/share/info:$INFOPATH
MANPATH=$HOME/local/share/man:/usr/local/share/man:$MANPATH

if [ -d $HOME/local/lib64/python ]; then
    PYTHONPATH=$HOME/local/lib64/python:$PYTHONPATH
fi
if [ -d $HOME/local/lib/python2.7/site-packages ]; then
    PYTHONPATH=$HOME/local/lib/python2.7/site-packages:$PYTHONPATH
fi

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

PATH=$HOME/bin:$PATH

EDITOR=emacsclient
ALTERNATE_EDITOR="vim"

export PATH CPATH PKG_CONFIG_PATH INFOPATH MANPATH PYTHONPATH EDITOR ALTERNATE_EDITOR

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

if which gpg-agent &>/dev/null; then
    gnupginf="${HOME}/.gpg-agent-info"
    if pgrep -u "${USER}" gpg-agent >/dev/null 2>&1; then
        eval `cat ${gnupginf}`
        eval `cut -d= -f1 ${gnupginf} | xargs echo export`
    else
        eval `gpg-agent -s --enable-ssh-support --daemon`
    fi
fi

if which ssh-add >/dev/null 2>/dev/null && [ ! -z "$SSH_AGENT_PID" ] && ps ax | grep "$SSH_AGENT_PID" | grep -q -v grep; then
    if ! ssh-add -l | grep -q .ssh/id_rsa; then
        ssh-add
    fi
fi
