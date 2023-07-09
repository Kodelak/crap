#!/bin/bash
# This line specifies that this script should be run using the Bash shell

HOSTNAME=example.ddns.org
# This line sets a variable called HOSTNAME to the value 'example.ddns.org'. This could be any domain name that resolves to your desired IP address.

if [[ $EUID -ne 0 ]]; then
# This checks if the effective user ID of the current user is not 0. User ID 0 is usually the root user.
# -ne stands for 'not equal'

   echo "This script must be run as root"
   # If the user is not root, then this message is printed to the console.

   exit 1
   # This line ends the script immediately, with a status of 1. This indicates that an error occurred.
fi
# Ends the if statement.

new_ip=$(host $HOSTNAME | head -n1 | cut -f4 -d ' ')
# This line uses the 'host' command to get the IP address associated with the hostname.
# 'head -n1' is used to take the first line of output, and 'cut -f4 -d ' ' ' is used to extract the 4th field separated by spaces (where the IP is).
# The resulting IP is stored in the variable 'new_ip'.

old_ip=$(/usr/sbin/ufw status | grep $HOSTNAME | head -n1 | tr -s ' ' | cut -f3 -d ' ')
# This line gets the old IP from the firewall rules using ufw status, grep, head, tr, and cut commands.
# ufw status gets the firewall status, grep filters lines including the hostname, head -n1 gets the first line,
# tr -s ' ' replaces multiple spaces with a single one, and cut -f3 -d ' ' gets the 3rd field which is the IP.
# The resulting IP is stored in the variable 'old_ip'.

if [ "$new_ip" = "$old_ip" ] ; then
# This checks if the new_ip and old_ip are the same.

    echo IP address has not changed
    # If the IPs are the same, then this message is printed to the console.
else
# If the IPs are not the same, then the script continues here.

    if [ -n "$old_ip" ] ; then
    # Checks if the old_ip is not empty. '-n' checks for a non-zero length string.

        /usr/sbin/ufw delete allow from $old_ip to any
        # If the old_ip exists, then this line deletes the firewall rule that allows any traffic from the old IP.
    fi
    # Ends the if statement.

    /usr/sbin/ufw allow from $new_ip to any comment $HOSTNAME
    # This line creates a new firewall rule that allows any traffic from the new IP. It also attaches a comment with the hostname to the rule.

    echo iptables have been updated
    # This message is printed to the console to indicate that the firewall rules have been updated.
fi
# Ends the if statement.
