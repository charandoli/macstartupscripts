#!/bin/bash

echo "Installing Xcode Command Line Tools..."
xcode-select --install

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Updating Homebrew..."
brew update

echo "Installing core tools..."
brew install git
brew install wget
brew install maven
brew install azure-cli
brew install kubectl
brew install kubectx
brew install docker
brew install docker-compose
brew install openjdk@17
brew install python
brew install tmux
brew install iterm2

echo "Installing Visual Studio Code..."
brew install --cask visual-studio-code

echo "Setting Java 17 as default..."
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zprofile
echo 'export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"' >> ~/.zprofile
source ~/.zprofile

echo "Installing Docker Desktop..."
brew install --cask docker

echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing Python data science packages..."
pip3 install --upgrade pip
pip3 install numpy pandas scipy matplotlib seaborn scikit-learn jupyterlab

echo "Setting up Zsh plugins..."
brew install zsh-autosuggestions zsh-syntax-highlighting

echo "Enabling Zsh plugins in .zshrc..."
{
  echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
} >> ~/.zshrc

echo "Done! Launch Docker Desktop and VS Code to complete setup."

