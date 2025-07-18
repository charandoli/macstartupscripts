#!/bin/bash

# This script sets up a development environment on macOS.
# It checks for existing installations and configurations
# to avoid re-running completed steps. It will also report
# on successes, failures, and skipped items.

# --- Report Arrays ---
SUCCESS_INSTALLS=()
FAILED_INSTALLS=()
SKIPPED_INSTALLS=()
SUCCESS_CONFIGS=()
FAILED_CONFIGS=()
SKIPPED_CONFIGS=()

# --- Helper function for installation ---
# Usage: install_package "package_name" "install_command"
# Example: install_package "git" "brew install git"
install_package() {
    local package=$1
    local command=$2

    echo "Installing $package..."
    eval $command
    if [ $? -eq 0 ]; then
        echo "$package installed successfully."
        SUCCESS_INSTALLS+=("$package")
    else
        echo "ERROR: Failed to install $package."
        FAILED_INSTALLS+=("$package")
    fi
}

echo "Starting development environment setup..."
echo "A summary report will be generated at the end."
echo "-----------------------------------------------------"


# --- Xcode Command Line Tools ---
echo "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  # This requires user interaction, so we can't easily script the success/fail check here.
  # We will assume the user handles this prompt.
  SUCCESS_CONFIGS+=("Xcode Command Line Tools (user initiated)")
else
  echo "Xcode Command Line Tools are already installed. Skipping."
  SKIPPED_CONFIGS+=("Xcode Command Line Tools")
fi

# --- Homebrew ---
echo "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -eq 0 ]; then
      SUCCESS_CONFIGS+=("Homebrew")
  else
      FAILED_CONFIGS+=("Homebrew")
      echo "FATAL: Homebrew installation failed. Cannot proceed with package installations."
      # The script will still generate a report of what happened so far.
      exit 1
  fi
else
  echo "Homebrew is already installed. Skipping installation."
  SKIPPED_CONFIGS+=("Homebrew")
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
    install_package "$tool" "brew install $tool"
  else
    echo "$tool is already installed. Skipping."
    SKIPPED_INSTALLS+=("$tool")
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
    install_package "stripe" "brew install stripe"
else
    echo "Stripe CLI is already installed. Skipping."
    SKIPPED_INSTALLS+=("Stripe CLI")
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
        install_package "$app" "brew install --cask $app"
    else
        echo "$app is already installed. Skipping."
        SKIPPED_INSTALLS+=("$app (cask)")
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
  if [ $? -eq 0 ]; then SUCCESS_CONFIGS+=("Java 17 Symlink"); else FAILED_CONFIGS+=("Java 17 Symlink"); fi
else
  echo "Java 17 symlink already exists. Skipping."
  SKIPPED_CONFIGS+=("Java 17 Symlink")
fi

if ! grep -qF "$JAVA_HOME_LINE" ~/.zprofile; then
  echo "Adding Java 17 PATH to ~/.zprofile..."
  echo "$JAVA_HOME_LINE" >> ~/.zprofile
  SUCCESS_CONFIGS+=("Java 17 PATH in .zprofile")
else
  echo "Java 17 PATH already in ~/.zprofile. Skipping."
  SKIPPED_CONFIGS+=("Java 17 PATH in .zprofile")
fi

if ! grep -qF "$CPPFLAGS_LINE" ~/.zprofile; then
    echo "Adding Java 17 CPPFLAGS to ~/.zprofile..."
    echo "$CPPFLAGS_LINE" >> ~/.zprofile
    SUCCESS_CONFIGS+=("Java 17 CPPFLAGS in .zprofile")
else
    echo "Java 17 CPPFLAGS already in ~/.zprofile. Skipping."
    SKIPPED_CONFIGS+=("Java 17 CPPFLAGS in .zprofile")
fi

echo "Sourcing .zprofile to apply changes..."
source ~/.zprofile

# --- Oh My Zsh ---
echo "Checking for Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  if [ $? -eq 0 ]; then SUCCESS_CONFIGS+=("Oh My Zsh"); else FAILED_CONFIGS+=("Oh My Zsh"); fi
else
  echo "Oh My Zsh is already installed. Skipping."
  SKIPPED_CONFIGS+=("Oh My Zsh")
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
    install_package "$package (pip)" "pip3 install $package"
  else
    echo "$package is already installed. Skipping."
    SKIPPED_INSTALLS+=("$package (pip)")
  fi
done

# --- Zsh Plugins ---
echo "Checking and installing Zsh plugins..."
if ! brew list zsh-autosuggestions &>/dev/null; then
    install_package "zsh-autosuggestions" "brew install zsh-autosuggestions"
else
    echo "zsh-autosuggestions already installed."
    SKIPPED_INSTALLS+=("zsh-autosuggestions")
fi

if ! brew list zsh-syntax-highlighting &>/dev/null; then
    install_package "zsh-syntax-highlighting" "brew install zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting already installed."
    SKIPPED_INSTALLS+=("zsh-syntax-highlighting")
fi

# --- Zsh Plugin Configuration in .zshrc ---
AUTOSUGGESTIONS_LINE="source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
SYNTAX_HIGHLIGHTING_LINE="source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

echo "Enabling Zsh plugins in .zshrc..."
if ! grep -qF "$AUTOSUGGESTIONS_LINE" ~/.zshrc; then
  echo "Adding zsh-autosuggestions to .zshrc..."
  echo "$AUTOSUGGESTIONS_LINE" >> ~/.zshrc
  SUCCESS_CONFIGS+=("zsh-autosuggestions in .zshrc")
else
  echo "zsh-autosuggestions already configured in .zshrc."
  SKIPPED_CONFIGS+=("zsh-autosuggestions in .zshrc")
fi

if ! grep -qF "$SYNTAX_HIGHLIGHTING_LINE" ~/.zshrc; then
  echo "Adding zsh-syntax-highlighting to .zshrc..."
  echo "$SYNTAX_HIGHLIGHTING_LINE" >> ~/.zshrc
  SUCCESS_CONFIGS+=("zsh-syntax-highlighting in .zshrc")
else
  echo "zsh-syntax-highlighting already configured in .zshrc."
  SKIPPED_CONFIGS+=("zsh-syntax-highlighting in .zshrc")
fi

# --- Final Report ---
echo ""
echo "====================================================="
echo "          Development Environment Setup Report"
echo "====================================================="
echo ""

if [ ${#SUCCESS_INSTALLS[@]} -ne 0 ]; then
    echo "✅ Successfully Installed Packages:"
    for item in "${SUCCESS_INSTALLS[@]}"; do
        echo "   - $item"
    done
    echo ""
fi

if [ ${#SUCCESS_CONFIGS[@]} -ne 0 ]; then
    echo "✅ Successfully Applied Configurations:"
    for item in "${SUCCESS_CONFIGS[@]}"; do
        echo "   - $item"
    done
    echo ""
fi

if [ ${#FAILED_INSTALLS[@]} -ne 0 ]; then
    echo "❌ Failed Installations (Please review):"
    for item in "${FAILED_INSTALLS[@]}"; do
        echo "   - $item"
    done
    echo ""
fi

if [ ${#FAILED_CONFIGS[@]} -ne 0 ]; then
    echo "❌ Failed Configurations (Please review):"
    for item in "${FAILED_CONFIGS[@]}"; do
        echo "   - $item"
    done
    echo ""
fi

if [ ${#SKIPPED_INSTALLS[@]} -ne 0 ]; then
    echo "⏩ Skipped Packages (Already Installed):"
    for item in "${SKIPPED_INSTALLS[@]}"; do
        echo "   - $item"
    done
    echo ""
fi

if [ ${#SKIPPED_CONFIGS[@]} -ne 0 ]; then
    echo "⏩ Skipped Configurations (Already Present):"
    for item in "${SKIPPED_CONFIGS[@]}"; do
        echo "   - $item"
    done
    echo ""
fi

echo "-----------------------------------------------------"
echo "Setup script complete!"
echo "Please launch new applications to complete their initial setup."
echo "You may need to restart your terminal for all changes to take effect."
echo "-----------------------------------------------------"

