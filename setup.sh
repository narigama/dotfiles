#!/bin/bash                                                                                                                                                                       
set -eu
DEBIAN_FRONTEND=noninteractive

# setup dirs
mkdir -p $HOME/.local/bin
PATH=$HOME/.local/bin:$PATH

# install some packages
echo setting up base packages
sudo apt-get update -qq
sudo apt-get install -yqq $(cat packages-debian | grep -v "^#" | grep "\S")

# neovim
if [[ -z $(which nvim) ]]
then
    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb
    sudo dpkg -i nvim-linux64.deb
    rm nvim-linux64.deb
fi
echo $(nvim --version | head -n1) is installed

# age
if [[ -z $(which age) ]]
then
    AGE_VERSION=1.1.1
    curl -sL https://github.com/FiloSottile/age/releases/download/v$AGE_VERSION/age-v$AGE_VERSION-linux-amd64.tar.gz | tar -xvz
    mv age/age* $HOME/.local/bin
    rm -rf age
fi
echo age $(age --version) is installed

# fish
if [[ -z $(which fish) ]]
then
    sudo apt-add-repository ppa:fish-shell/release-3
    sudo apt-get update -qq
    sudo apt-get install -yqq fish
    sudo chsh -s $(which fish) $USER
fi
echo fish $(fish --version | awk '{print $3}') is installed

# k9s
if [[ -z $(which k9s) ]]
then
    mkdir k9s
    cd k9s
    wget https://github.com/derailed/k9s/releases/download/v0.27.2/k9s_Linux_amd64.tar.gz
    tar -xvzf k9s_Linux_amd64.tar.gz
    mv k9s $HOME/.local/bin
    chmod +x $HOME/.local/bin/k9s
    cd ..
    rm -rf k9s
fi
echo k9s $(k9s version -s | head -n1 | awk '{print $2}') is installed

# python
if [[ -z $(which python3.10) ]]
then
    # add deadsnakes to get all python versions
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update -qq

    # setup python3.10 and setup poetry
    sudo apt-get install -yqq python3.10 python3.10-dev python3.10-venv
    python3.10 -m pip install --user -U pip setuptools poetry yt-dlp
    python3.10 -m poetry config virtualenvs.in-project true
fi
echo $(python --version) is installed

# node
if [[ -z $(which node) ]]
then
    curl -sL https://deb.nodesource.com/setup_19.x | sudo bash -
    sudo apt-get update -qq
    sudo apt-get install -yqq nodejs
fi
echo node $(node --version) is installed

# rust and binaries
if [[ -z $(which cargo) ]]
then
    echo installing cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    $HOME/.cargo/bin/cargo install binstall
    $HOME/.cargo/bin/cargo binstall -y bat exa ouch ripgrep starship tokei zoxide
fi
echo cargo $(cargo --version | awk '{print $2}') is installed

# grab chezmoi and apply dotfiles
if [[ -z $(which chezmoi) ]]
then
    echo installing chezmoi
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
    chezmoi init --apply git@github.com:narigama/dotfiles.git
fi
echo $(chezmoi --version | cut -d, -f1) is installed
