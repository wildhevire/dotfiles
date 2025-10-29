#!/usr/bin/env bash
set -e

SUCCESS=0
FAILURE=1
MISSING_FILES=2
UNSUPPORTED=3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_error() {
    echo -e "$1" >&2
}

print_info() {
    echo -e "$1"
}

if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run with root privileges"
    exit $FAILURE
fi

print_info "Installing Battery Manager..."
echo

if [ -n "$PKEXEC_UID" ]; then
    ACTUAL_USER=$(getent passwd "$PKEXEC_UID" | cut -d: -f1)
else
    ACTUAL_USER="$SUDO_USER"
fi

if [ -z "$ACTUAL_USER" ]; then
    print_error "Could not determine the actual user"
    exit $FAILURE
fi

print_info "Installing for user: $ACTUAL_USER"
echo

print_info "Checking required files..."

MISSING_FILES_LIST=()

if [ ! -f "$SCRIPT_DIR/battery-paths.conf" ]; then
    MISSING_FILES_LIST+=("battery-paths.conf")
fi

if [ ! -f "$SCRIPT_DIR/templates/battery-manager.sh" ]; then
    MISSING_FILES_LIST+=("battery-manager.sh")
fi

if [ ! -f "$SCRIPT_DIR/templates/battery-manager.policy" ]; then
    MISSING_FILES_LIST+=("battery-manager.policy")
fi

if [ ! -f "$SCRIPT_DIR/templates/battery-manager.rules" ]; then
    MISSING_FILES_LIST+=("battery-manager.rules")
fi

if [ ${#MISSING_FILES_LIST[@]} -gt 0 ]; then
    print_error "Missing required files in $SCRIPT_DIR:"
    for file in "${MISSING_FILES_LIST[@]}"; do
        print_error "  - $file"
    done
    exit $MISSING_FILES
fi

print_info "All required files found"

print_info "Checking battery paths..."
BATTERY_PATHS=($(grep -v '^#' "$SCRIPT_DIR/battery-paths.conf" | grep -v '^$'))
EXISTING_PATHS=()

for path in "${BATTERY_PATHS[@]}"; do
    if [ -f "$path" ]; then
        EXISTING_PATHS+=("$path")
    fi
done

if [ ${#EXISTING_PATHS[@]} -eq 0 ]; then
    print_error "None of the battery control files exist. Please check your hardware compatibility."
    exit $UNSUPPORTED
fi

print_info "Found ${#EXISTING_PATHS[@]} compatible battery control file(s)"

print_info "Installing battery manager script..."
BATTERY_MANAGER_SCRIPT="/usr/bin/battery-manager-$ACTUAL_USER"

SHEBANG=$(head -n 1 "$SCRIPT_DIR/templates/battery-manager.sh")
echo "$SHEBANG" > "$BATTERY_MANAGER_SCRIPT"
echo "" >> "$BATTERY_MANAGER_SCRIPT"

echo "BATTERY_PATHS=(" >> "$BATTERY_MANAGER_SCRIPT"
for path in "${EXISTING_PATHS[@]}"; do
    echo "    \"$path\"" >> "$BATTERY_MANAGER_SCRIPT"
done
echo ")" >> "$BATTERY_MANAGER_SCRIPT"

echo "" >> "$BATTERY_MANAGER_SCRIPT"

tail -n +2 "$SCRIPT_DIR/templates/battery-manager.sh" >> "$BATTERY_MANAGER_SCRIPT"

chmod +x "$BATTERY_MANAGER_SCRIPT"

print_info "Battery manager script created from $SCRIPT_DIR/templates/battery-manager.sh with compatible paths"
print_info "Script installed at $BATTERY_MANAGER_SCRIPT"

print_info "Creating log file..."
touch /var/log/battery-manager.log
chmod 644 /var/log/battery-manager.log
print_info "Log file created at /var/log/battery-manager.log"

print_info "Creating polkit policy..."

POLICY_FILE="/usr/share/polkit-1/actions/com.local.battery-manager.$ACTUAL_USER.policy"

sed -e "s/ACTUAL_USER_PLACEHOLDER/$ACTUAL_USER/g" \
    "$SCRIPT_DIR/templates/battery-manager.policy" > "$POLICY_FILE"

print_info "Polkit policy copied from $SCRIPT_DIR/templates/battery-manager.policy"
print_info "Polkit policy created at $POLICY_FILE"
print_info "Creating polkit rule..."

RULES_FILE="/etc/polkit-1/rules.d/50-battery-manager-$ACTUAL_USER.rules"

sed "s/ACTUAL_USER_PLACEHOLDER/$ACTUAL_USER/g" \
    "$SCRIPT_DIR/templates/battery-manager.rules" > "$RULES_FILE"

print_info "Polkit rule copied from $SCRIPT_DIR/templates/battery-manager.rules"
print_info "Polkit rule created for user: $ACTUAL_USER at $RULES_FILE"

print_info "Restarting polkit..."
if systemctl restart polkit 2>/dev/null; then
    print_info "Polkit restarted"
else
    print_info "Could not restart polkit automatically, you may need to reboot"
fi

print_info "Creating uninstall script..."
UNINSTALL_SCRIPT="$SCRIPT_DIR/uninstall-battery-manager.sh"


if [ -f "$SCRIPT_DIR/templates/uninstall-template" ]; then
    SHEBANG=$(head -n 1 "$SCRIPT_DIR/templates/uninstall-template")
else
    SHEBANG="#!/usr/bin/env bash"
fi
echo "$SHEBANG" > "$UNINSTALL_SCRIPT"
echo "" >> "$UNINSTALL_SCRIPT"

cat >> "$UNINSTALL_SCRIPT" << EOF
SCRIPT_PATH="$BATTERY_MANAGER_SCRIPT"
POLICY_PATH="$POLICY_FILE"
RULE_PATH="$RULES_FILE"
LOG_PATH="/var/log/battery-manager.log"

EOF

if [ -f "$SCRIPT_DIR/templates/uninstall-template" ]; then
    tail -n +2 "$SCRIPT_DIR/templates/uninstall-template" >> "$UNINSTALL_SCRIPT"
fi

chmod 744 "$UNINSTALL_SCRIPT"
chown root:root "$UNINSTALL_SCRIPT"

print_info "Uninstall script created at $UNINSTALL_SCRIPT"


echo
print_info "Installation complete!"
echo
print_info "Log file: /var/log/battery-manager.log"
print_info "User-specific script: $BATTERY_MANAGER_SCRIPT"
print_info "User-specific policy: $POLICY_FILE"
print_info "User-specific rules: $RULES_FILE"
print_info "User-specific uninstall script: $UNINSTALL_SCRIPT"
