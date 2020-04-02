# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git composer history history-substring-search
)

source $ZSH/oh-my-zsh.sh

# custom exports
export PHP_IDE_CONFIG="serverName=zed"
export XDEBUG_CONFIG="profiler_enable=1"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# custom aliases
alias console="php /data/shop/development/current/vendor/bin/console"
alias codecept="php /data/shop/development/current/vendor/bin/codecept"
alias phpunit="php /data/shop/development/current/vendor/bin/phpunit"
alias psalm="php /data/shop/development/current/vendor/bin/psalm"
alias psalter="php /data/shop/development/current/vendor/bin/psalter"

alias ll="ls -gFlash"

