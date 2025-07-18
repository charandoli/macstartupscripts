#!/bin/bash

# This script sets up a development environment on macOS.
# It checks for existing installations and configurations
# to avoid re-running completed steps.

echo "Starting development environment setup..."

# --- Xcode Command Line Tools ---
echo "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
else
  echo "Xcode Command Line Tools are already installed. Skipping."
fi

# --- Homebrew ---
echo "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed. Skipping installation."
fi

echo "Updating Homebrew..."
brew update

# --- Core Homebrew Packages ---
CORE_TOOLS=(
  git
  wget
  maven
  azure-cli
  kubectl
  kubectx
  docker
  docker-compose
  openjdk@17
  python
  tmux
  iterm2
  k9s
  1password-cli
  nodejs
  mkcert
  azure-functions-core-tools@4
)

echo "Checking and installing core tools..."
for tool in "${CORE_TOOLS[@]}"; do
  if ! brew list "$tool" &>/dev/null; then
    echo "Installing $tool..."
    brew install "$tool"
  else
    echo "$tool is already installed. Skipping."
  fi
done

# --- Taps and Tools from Taps ---
echo "Checking for custom taps and installing tools..."

# Stripe CLI
if ! brew tap | grep -q "^stripe/stripe-cli$"; then
    echo "Tapping stripe/stripe-cli..."
    brew tap stripe/stripe-cli
else
    echo "stripe/stripe-cli already tapped."
fi

if ! brew list stripe &>/dev/null; then
    echo "Installing Stripe CLI..."
    brew install stripe
else
    echo "Stripe CLI is already installed. Skipping."
fi


# --- Homebrew Casks ---
CASK_APPS=(
  visual-studio-code
  docker
  intellij-idea
  github-desktop
  git-fork
  microsoft-azure-storage-explorer
)

echo "Checking and installing applications (Casks)..."
for app in "${CASK_APPS[@]}"; do
    if ! brew list --cask "$app" &>/dev/null; then
        echo "Installing $app..."
        brew install --cask "$app"
    else
        echo "$app is already installed. Skipping."
    fi
done


# --- Java 17 Configuration ---
JAVA_SYMLINK_PATH="/Library/Java/JavaVirtualMachines/openjdk-17.jdk"
JAVA_HOME_LINE='export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"'
CPPFLAGS_LINE='export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"'

echo "Checking Java 17 configuration..."
if [ ! -L "$JAVA_SYMLINK_PATH" ]; then
  echo "Setting Java 17 as default..."
  sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk "$JAVA_SYMLINK_PATH"
else
  echo "Java 17 symlink already exists. Skipping."
fi

if ! grep -qF "$JAVA_HOME_LINE" ~/.zprofile; then
  echo "Adding Java 17 PATH to ~/.zprofile..."
  echo "$JAVA_HOME_LINE" >> ~/.zprofile
else
  echo "Java 17 PATH already in ~/.zprofile. Skipping."
fi

if ! grep -qF "$CPPFLAGS_LINE" ~/.zprofile; then
    echo "Adding Java 17 CPPFLAGS to ~/.zprofile..."
    echo "$CPPFLAGS_LINE" >> ~/.zprofile
else
    echo "Java 17 CPPFLAGS already in ~/.zprofile. Skipping."
fi

echo "Sourcing .zprofile to apply changes..."
source ~/.zprofile

# --- Oh My Zsh ---
echo "Checking for Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  # The installer script might try to run zsh at the end, which can be problematic in a script.
  # We use the CHSH=no and RUNZSH=no flags to prevent this.
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
else
  echo "Oh My Zsh is already installed. Skipping."
fi

# --- Python Data Science Packages ---
PYTHON_PACKAGES=(
  numpy
  pandas
  scipy
  matplotlib
  seaborn
  scikit-learn
  jupyterlab
)

echo "Checking and installing Python data science packages..."
pip3 install --upgrade pip
for package in "${PYTHON_PACKAGES[@]}"; do
  if ! pip3 show "$package" &>/dev/null; then
    echo "Installing $package..."
    pip3 install "$package"
  else
    echo "$package is already installed. Skipping."
  fi
done

# --- Zsh Plugins ---
echo "Checking and installing Zsh plugins..."
if ! brew list zsh-autosuggestions &>/dev/null; then
    brew install zsh-autosuggestions
else
    echo "zsh-autosuggestions already installed."
fi

if ! brew list zsh-syntax-highlighting &>/dev/null; then
    brew install zsh-syntax-highlighting
else
    echo "zsh-syntax-highlighting already installed."
fi

# --- Zsh Plugin Configuration in .zshrc ---
AUTOSUGGESTIONS_LINE="source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
SYNTAX_HIGHLIGHTING_LINE="source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

echo "Enabling Zsh plugins in .zshrc..."
if ! grep -qF "$AUTOSUGGESTIONS_LINE" ~/.zshrc; then
  echo "Adding zsh-autosuggestions to .zshrc..."
  echo "$AUTOSUGGESTIONS_LINE" >> ~/.zshrc
else
  echo "zsh-autosuggestions already configured in .zshrc."
fi

if ! grep -qF "$SYNTAX_HIGHLIGHTING_LINE" ~/.zshrc; then
  echo "Adding zsh-syntax-highlighting to .zshrc..."
  echo "$SYNTAX_HIGHLIGHTING_LINE" >> ~/.zshrc
else
  echo "zsh-syntax-highlighting already configured in .zshrc."
fi

echo ""
echo "-----------------------------------------------------"
echo "Setup script complete!"
echo "Please launch Docker Desktop, VS Code, IntelliJ IDEA, GitHub Desktop, Fork, and Azure Storage Explorer to complete their initial setup."
echo "You may need to restart your terminal for all changes to take effect."
echo "-----------------------------------------------------"

