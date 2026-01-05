#!/bin/bash

echo "🔧 Installation des outils pour développeur web..."

# Vérifier si Homebrew est installé, sinon l'installer
if ! command -v brew &>/dev/null; then
    echo "🛠️ Homebrew non détecté, installation..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installation de Oh my Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Mettre à jour Brew et installer les outils du Brewfile
echo "📦 Installation des logiciels via Brew..."
brew update
brew bundle --file=Brewfile

# Redémarrer le shell pour appliquer les changements
exec zsh

# Configurer nvm (Node Version Manager)
if ! command -v nvm &>/dev/null; then
    echo "🔧 NVM non détecté, installation..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' >> ~/.zshrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc

    echo 'autoload -U add-zsh-hook
    load-nvmrc() {
        local node_version="$(nvm version)"
        local nvmrc_path="$(nvm_find_nvmrc)"
        if [ -n "$nvmrc_path" ]; then
            local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
            if [ "$nvmrc_node_version" = "N/A" ]; then
                nvm install
            elif [ "$nvmrc_node_version" != "$node_version" ]; then
                nvm use
            fi
        elif [ "$node_version" != "$(nvm version default)" ]; then
            echo "Reverting to nvm default version"
            nvm use default
        fi
    }
    add-zsh-hook chpwd load-nvmrc
    load-nvmrc' >> ~/.zshrc

    echo 'export NODE_OPTIONS=--max-old-space-size=4000' >> ~/.zshrc
fi

# Configuration de Zsh + Starship (Prompt)
echo "🌟 Configuration de Zsh et Starship..."
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

# Configuration de rbenv
echo "Installation de l'environnement Ruby..."

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
~/.rbenv/bin/rbenv init
exec zsh
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
git clone https://github.com/rbenv/rbenv-vars.git "$(rbenv root)"/plugins/rbenv-vars
rbenv install 3.2.0
gem install bundler
gem install foreman

echo "Installation de scalingo..."
curl -O https://cli-dl.scalingo.com/install && bash install

echo "Configuration de dnsmasq..."
mkdir -pv $(brew --prefix)/etc/
echo 'address=/.test/127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
echo 'port=53' >> $(brew --prefix)/etc/dnsmasq.conf
sudo mkdir -v /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'
sudo brew services start dnsmasq

exec zsh
