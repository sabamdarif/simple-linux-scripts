#!/bin/bash
set -Eeuo pipefail

# ============================================================================
# ZSH Setup Script with Nerd Fonts and Dotfiles
# ============================================================================
# This script will:
# - Install zsh (pacman/dnf/apt support)
# - Change default shell to zsh
# - Install JetBrainsMono Nerd Font
# - Download and configure dotfiles with backups
# ============================================================================

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$*" >&2
}

log_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$*" >&2
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$*" >&2
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$*" >&2
}

# Error handling
trap 'log_error "Script failed on line $LINENO"' ERR

# ============================================================================
# Confirmation Prompt
# ============================================================================
show_intro_and_confirm() {
    echo
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗"
    echo -e "║                    ZSH Setup Script                                ║"
    echo -e "╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo "This script will perform the following actions:"
    echo
    echo -e "  ${GREEN}✓${NC} Install ZSH (if not already installed)"
    echo -e "  ${GREEN}✓${NC} Change your default shell to ZSH"
    echo -e "  ${GREEN}✓${NC} Install JetBrainsMono Nerd Font (~40MB download)"
    echo -e "  ${GREEN}✓${NC} Download dotfiles from sabamdarif/dotfiles repository:"
    echo "      • .zshrc (with Powerlevel10k configuration)"
    echo "      • .shell_functions"
    echo "      • .shell_aliases"
    echo "      • .p10k.zsh"
    echo -e "  ${GREEN}✓${NC} Backup your existing dotfiles (if any)"
    echo -e "  ${GREEN}✓${NC} Source the new ZSH configuration"
    echo
    echo -e "${YELLOW}Note:${NC} This script requires sudo privileges for package installation"
    echo "      and changing the default shell."
    echo

    # Prompt for confirmation (redirect from tty for piped execution)
    echo -ne "${BLUE}Do you want to continue? (y/n):${NC} "
    read -r response </dev/tty

    case "$response" in
    [yY][eE][sS] | [yY])
        log_success "Starting installation..."
        echo
        return 0
        ;;
    *)
        log_info "Installation cancelled by user"
        exit 0
        ;;
    esac
}

# ============================================================================
# Detect Package Manager
# ============================================================================
detect_package_manager() {
    if command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v apt &>/dev/null; then
        echo "apt"
    else
        log_error "No supported package manager found (pacman/dnf/apt)"
        return 1
    fi
}

# ============================================================================
# Install ZSH
# ============================================================================
install_zsh() {
    local pkg_manager
    pkg_manager=$(detect_package_manager)

    # Check if zsh is already installed
    if command -v zsh &>/dev/null; then
        log_info "zsh is already installed: $(zsh --version)"
        return 0
    fi

    log_info "Installing zsh using $pkg_manager..."

    case "$pkg_manager" in
    pacman)
        sudo pacman -S --noconfirm zsh || {
            log_error "Failed to install zsh with pacman"
            return 1
        }
        ;;
    dnf)
        sudo dnf install -y zsh || {
            log_error "Failed to install zsh with dnf"
            return 1
        }
        ;;
    apt)
        sudo apt update || log_warn "apt update failed, continuing..."
        sudo apt install -y zsh || {
            log_error "Failed to install zsh with apt"
            return 1
        }
        ;;
    *)
        log_error "Unsupported package manager: $pkg_manager"
        return 1
        ;;
    esac

    log_success "zsh installed successfully"
}

# ============================================================================
# Change Shell to ZSH
# ============================================================================
change_shell_to_zsh() {
    local zsh_path
    zsh_path=$(command -v zsh) || {
        log_error "zsh not found in PATH"
        return 1
    }

    # Check current shell
    if [[ "$SHELL" == "$zsh_path" ]]; then
        log_info "Shell is already set to zsh"
        return 0
    fi

    log_info "Changing default shell to zsh..."

    # Verify zsh is in /etc/shells
    if ! grep -q "^${zsh_path}$" /etc/shells; then
        log_warn "Adding $zsh_path to /etc/shells"
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change shell
    chsh -s "$zsh_path" || {
        log_error "Failed to change shell to zsh"
        return 1
    }

    log_success "Shell changed to zsh (will take effect on next login)"
}

# ============================================================================
# Install Nerd Font (JetBrainsMono)
# ============================================================================
install_nerd_font() {
    local fonts_dir="$HOME/.fonts"
    local font_name="JetBrainsMono"
    local font_version="v3.2.1"
    local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${font_version}/${font_name}.zip"
    local tmpdir

    # Check if font already exists
    if [[ -d "$fonts_dir" ]] && find "$fonts_dir" -name "*JetBrainsMono*Nerd*" -print -quit | grep -q .; then
        log_info "JetBrainsMono Nerd Font already installed"
        return 0
    fi

    log_info "Installing JetBrainsMono Nerd Font..."

    # Create fonts directory
    mkdir -p "$fonts_dir" || {
        log_error "Failed to create fonts directory"
        return 1
    }

    # Create temporary directory
    tmpdir=$(mktemp -d) || {
        log_error "Failed to create temporary directory"
        return 1
    }

    # Ensure cleanup
    trap 'rm -rf "$tmpdir"' EXIT

    # Download font
    log_info "Downloading $font_name from GitHub releases..."
    if ! curl -fL --progress-bar -o "$tmpdir/${font_name}.zip" "$download_url"; then
        log_error "Failed to download font"
        return 1
    fi

    # Extract font
    log_info "Extracting font files..."
    if ! unzip -q "$tmpdir/${font_name}.zip" -d "$tmpdir/${font_name}"; then
        log_error "Failed to extract font (is unzip installed?)"
        return 1
    fi

    # Copy font files (only .ttf files, skip variable fonts)
    log_info "Installing font files to $fonts_dir..."
    find "$tmpdir/${font_name}" -name "*.ttf" ! -name "*Windows Compatible*" -exec cp {} "$fonts_dir/" \;

    # Update font cache
    log_info "Updating font cache..."
    if command -v fc-cache &>/dev/null; then
        fc-cache -fv "$fonts_dir" >/dev/null 2>&1 || log_warn "fc-cache failed, but font files were copied"
    else
        log_warn "fc-cache not found, you may need to refresh font cache manually"
    fi

    log_success "JetBrainsMono Nerd Font installed successfully"
}

# ============================================================================
# Download Dotfiles with Backup
# ============================================================================
download_dotfiles() {
    local -A files=(
        [".zshrc"]="https://raw.githubusercontent.com/sabamdarif/dotfiles/refs/heads/main/.zshrc"
        [".shell_functions"]="https://raw.githubusercontent.com/sabamdarif/dotfiles/refs/heads/main/.shell_functions"
        [".p10k.zsh"]="https://raw.githubusercontent.com/sabamdarif/dotfiles/refs/heads/main/.p10k.zsh"
        [".shell_aliases"]="https://raw.githubusercontent.com/sabamdarif/dotfiles/refs/heads/main/.shell_aliases"
    )

    local backup_dir
    backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    local backup_created=false

    log_info "Downloading dotfiles from GitHub..."

    for file in "${!files[@]}"; do
        local url="${files[$file]}"
        local target="$HOME/$file"

        # Backup existing file if it exists
        if [[ -f "$target" ]]; then
            if [[ "$backup_created" == false ]]; then
                mkdir -p "$backup_dir" || {
                    log_error "Failed to create backup directory"
                    return 1
                }
                backup_created=true
                log_info "Backing up existing files to: $backup_dir"
            fi

            cp "$target" "$backup_dir/$file" || {
                log_error "Failed to backup $file"
                return 1
            }
            log_info "Backed up: $file"
        fi

        # Download new file
        log_info "Downloading: $file"
        if ! curl -fsSL -o "$target" "$url"; then
            log_error "Failed to download $file from $url"
            return 1
        fi
    done

    if [[ "$backup_created" == true ]]; then
        log_success "Original files backed up to: $backup_dir"
    fi

    log_success "All dotfiles downloaded successfully"
}

# ============================================================================
# Source ZSH Configuration
# ============================================================================
source_zsh_config() {
    local zsh_path
    zsh_path=$(command -v zsh) || {
        log_error "zsh not found"
        return 1
    }

    log_info "Attempting to source .zshrc..."

    # Try to source the configuration
    if "$zsh_path" -i -c "source $HOME/.zshrc; exit" 2>/dev/null; then
        log_success "Successfully sourced .zshrc"
    else
        log_warn "Failed to source .zshrc, but configuration files were written"
        log_info "You can manually source it by running: source ~/.zshrc"
    fi
}

# ============================================================================
# Main Execution
# ============================================================================
main() {
    # Show introduction and get user confirmation
    show_intro_and_confirm

    log_info "Starting ZSH setup script..."
    echo

    # Check dependencies
    local -a missing_deps=()
    for cmd in curl unzip; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing_deps[*]}"
        log_info "Please install them first (e.g., sudo apt install curl unzip)"
        exit 1
    fi

    # Execute setup steps
    install_zsh || exit 1
    echo

    change_shell_to_zsh || exit 1
    echo

    install_nerd_font || exit 1
    echo

    download_dotfiles || exit 1
    echo

    source_zsh_config || exit 1
    echo

    log_success "==================================================================="
    log_success "ZSH setup completed successfully!"
    log_success "==================================================================="
    echo
    log_info "Next steps:"
    log_info "1. Log out and log back in (or run: exec zsh)"
    log_info "2. Your terminal font to JetBrainsMono Nerd Font"
    log_info "3. Enjoy your new zsh setup with Powerlevel10k!"
    echo
    log_info "If .zshrc asks to configure p10k, run: p10k configure"
}

# Run main function
main "$@"
