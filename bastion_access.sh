#!/bin/bash

# This script simulates the access control mechanism of a Bastion Host
# protecting a Private Server in a cloud environment.
# It demonstrates how direct access to the private server is blocked,
# while access through the Bastion Host is allowed.

# --- Configuration (Conceptual IPs) ---
# Your local machine's IP (where you initiate connections from)
MY_LOCAL_IP="192.168.1.100"

# The Bastion Host's public IP. This is the only server exposed to the internet for SSH.
BASTION_HOST_IP="172.16.0.1"

# The Private Server's internal IP. This server is NOT directly exposed to the internet.
PRIVATE_SERVER_IP="10.0.0.10"

# --- Simulation Function ---
# Simulates an SSH connection attempt with basic access control logic.
# Arguments: source_ip, target_ip, [port]
simulate_ssh() {
    local source=$1
    local target=$2
    local port=${3:-22} # Default SSH port is 22

    echo "Attempting SSH connection from $source to $target:$port..."

    # --- Access Control Logic ---

    # Rule 1: Bastion Host (port 22) is publicly accessible from anywhere.
    # This simulates a firewall rule allowing SSH to the Bastion Host.
    if [[ "$target" == "$BASTION_HOST_IP" && "$port" == "22" ]]; then
        echo "  [SUCCESS] Connection to Bastion Host ($BASTION_HOST_IP) on port $port allowed. This is the secure entry point."
        return 0
    fi

    # Rule 2: Private Server is ONLY accessible from the Bastion Host.
    # All other direct connections to the Private Server are blocked by the firewall.
    if [[ "$target" == "$PRIVATE_SERVER_IP" ]]; then
        if [[ "$source" == "$BASTION_HOST_IP" ]]; then
            echo "  [SUCCESS] Connection to Private Server ($PRIVATE_SERVER_IP) from Bastion Host ($BASTION_HOST_IP) allowed."
            echo "  You are now 'inside' the private network, having jumped through the Bastion Host."
            return 0
        else
            echo "  [DENIED] Direct connection to Private Server ($PRIVATE_SERVER_IP) from $source is BLOCKED by firewall."
            echo "  Access to private servers is only allowed via the Bastion Host for enhanced security."
            return 1
        fi
    fi

    # Default: Other connections (e.g., non-SSH to bastion, or unknown targets/ports) are denied.
    echo "  [DENIED] Connection to $target:$port from $source is blocked by default security policy."
    return 1
}

# --- Demonstration Scenarios ---

echo "\n--- Scenario 1: Direct access attempt to Private Server from local machine ---"
# This simulates trying to SSH directly from your local machine to the private server.
# This should fail, as the private server is not exposed to the internet.
simulate_ssh "$MY_LOCAL_IP" "$PRIVATE_SERVER_IP"

echo "\n--- Scenario 2: Access attempt to Bastion Host from local machine ---"
# This simulates SSHing from your local machine to the Bastion Host.
# This should succeed, as the Bastion Host is the designated internet-facing server.
simulate_ssh "$MY_LOCAL_IP" "$BASTION_HOST_IP"

echo "\n--- Scenario 3: Access attempt from Bastion Host to Private Server ---"
# This simulates, *after* successfully connecting to the Bastion Host,
# trying to SSH from the Bastion Host to the private server.
# This should succeed, demonstrating the jump-host functionality.
echo "Simulating connection from Bastion Host to Private Server (after initial login to Bastion)..."
simulate_ssh "$BASTION_HOST_IP" "$PRIVATE_SERVER_IP"

echo "\n--- Summary ---"
echo "This example illustrates the core principle of using a Bastion Host:"
echo "1. Critical private servers are shielded from direct internet exposure."
echo "2. All access to private infrastructure is funneled through a single, hardened Bastion Host."
echo "This significantly reduces the attack surface and improves cloud security."
