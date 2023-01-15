#!/bin/bash                                                                                                                                                                       
set -eu
DEBIAN_FRONTEND=noninteractive

# setup dirs
mkdir -p $HOME/.local/bin

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
else
    echo $(nvim --version | head -n1) is installed
fi

# python
if [[ -z $(which python3.10) ]]
then
    # add deadsnakes to get all python versions
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update -qq

    # setup python3.10 and setup poetry
    sudo apt install -y python3.10 python3.10-dev python3.10-venv
    python3.10 -m pip install --user -U pip setuptools poetry yt-dlp
    python3.10 -m poetry config virtualenvs.in-project true
else
    echo $(python --version) is installed
fi

# node
if [[ -z $(which node) ]]
then
    curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
    sudo apt-get update -qq
    sudo apt-get install nodejs
else
    echo node $(node --version) is installed
fi

# rust and binaries
if [[ -z $(which cargo) ]]
then
    echo installing cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    $HOME/.cargo/bin/cargo install binstall
    $HOME/.cargo/bin/cargo binstall -y bat exa ouch ripgrep starship tokei zoxide
else
    echo cargo $(cargo --version | awk '{print $2}') is installed
fi

# grab chezmoi and apply dotfiles
if [[ -z $(which chezmoi) ]]
then
    echo installing chezmoi
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
    chezmoi init --apply git@github.com:narigama/dotfiles.git
else
    echo $(chezmoi --version | cut -d, -f1) is installed
fi
