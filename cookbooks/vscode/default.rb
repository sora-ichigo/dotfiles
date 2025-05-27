# Install Cursor application first
brew_cask_package 'cursor'

# Cursor extension management
# Simple and efficient implementation
extensions_path = "#{ENV['HOME']}/Library/Application Support/Cursor/User/extensions"

# Define dotfiles to be managed
dotfile "Library/Application Support/Cursor/User/settings.json"
dotfile "Library/Application Support/Cursor/User/keybindings.json"
dotfile "Library/Application Support/Cursor/User/extensions"

# Install only missing extensions (skip if no new extensions found)
execute 'Install missing Cursor extensions' do
  command <<-EOF
    # Skip if extensions file doesn't exist or is empty
    if [ ! -s "#{extensions_path}" ]; then
      echo "No extensions defined, skipping installation."
      exit 0
    fi

    # Create temporary working directory
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM

    # Get currently installed extensions
    cursor --list-extensions | sort > "$TEMP_DIR/installed.txt"

    # Get required extensions from config file
    cat "#{extensions_path}" | sort > "$TEMP_DIR/required.txt"

    # Find extensions that need to be installed
    MISSING=$(comm -13 "$TEMP_DIR/installed.txt" "$TEMP_DIR/required.txt")

    # Only install if there are missing extensions
    if [ -z "$MISSING" ]; then
      echo "All extensions already installed, skipping."
      exit 0
    else
      echo "Installing missing extensions:"
      echo "$MISSING"
      echo "$MISSING" | while read ext; do
        cursor --install-extension "$ext"
      done
      echo "Extensions installation completed."
    fi
  EOF

  # Make mitamae consider this command as always modified
  # but the command itself will internally skip if nothing to do
  not_if "false"
end

