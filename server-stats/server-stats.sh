#!/bin/bash

# server-stats.sh - Server Performance Analysis Script

# Colors for better readability
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================"
echo " SERVER PERFORMANCE STATS"
echo -e "========================${NC}"

# OS Version
echo -e "\n${YELLOW}🔸 OS Version:${NC}"
grep -E "PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"'

# Uptime
echo -e "\n${YELLOW}🔸 Uptime:${NC}"
uptime -p

# Load Average
echo -e "\n${YELLOW}🔸 Load Average:${NC}"
uptime | awk -F'load average:' '{ print $2 }' | sed 's/^ //'

# Logged in users
echo -e "\n${YELLOW}🔸 Currently Logged In Users:${NC}"
who | awk '{print $1}' | sort | uniq -c | awk '{print $2 ": " $1 " session(s)"}'
if [ $? -ne 0 ]; then
    echo "Unable to retrieve logged in users."
fi

# CPU Usage
echo -e "\n${YELLOW}🔸 CPU Usage:${NC}"
top -bn1 | grep "Cpu(s)" | awk '{used = $2 + $4; printf "Used: %.1f%%, Idle: %.1f%%\n", used, $8}'

# Memory Usage
echo -e "\n${YELLOW}🔸 Memory Usage:${NC}"
free -h | awk 'NR==2{printf "Used: %s / %s (%.2f%%)\n", $3, $2, ($3/$2)*100}'

# Disk Usage
echo -e "\n${YELLOW}🔸 Disk Usage (/):${NC}"
df -h / | awk 'NR==2{printf "Used: %s / %s (%s)\n", $3, $2, $5}'

# Top 5 processes by CPU
echo -e "\n${YELLOW}🔸 Top 5 Processes by CPU Usage:${NC}"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

# Top 5 processes by Memory
echo -e "\n${YELLOW}🔸 Top 5 Processes by Memory Usage:${NC}"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6

# Failed login attempts (last 10)
echo -e "\n${YELLOW}🔸 Last 10 Failed Login Attempts:${NC}"
FAILED_LOGINS=$(journalctl _COMM=sshd 2>/dev/null | grep "Failed password" | tail -n 10)
if [ -z "$FAILED_LOGINS" ]; then
    echo "No recent failed login attempts or insufficient permissions."
else
    echo "$FAILED_LOGINS"
fi

echo -e "\n${GREEN}✅ Done. Analysis Complete.${NC}"
