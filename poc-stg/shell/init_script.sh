#!/bin/bash

echo "Password Init"
echo "root:Qwer1234!" | sudo chpasswd

# System update
apt-get update
apt-get install -y bash-completion

# Create sysmgt group
groupadd -g 2001 sysmgt

# Create sysuser
useradd -m -u 2001 -g sysmgt -s /bin/bash sysuser
echo "sysuser:Qwer1234!" | chpasswd

# Configure sudoers (append)
if ! grep -q "sysuser" /etc/sudoers.d/sysuser 2>/dev/null; then
    echo "sysuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sysuser
    chmod 440 /etc/sudoers.d/sysuser
fi

# Configure /etc/hosts (append)
cat >> /etc/hosts << 'EOF'
10.20.100.175 git-poc.milkt.co.kr
10.20.100.174 nfs-poc.milkt.co.kr
EOF

# Remove HISTFILESIZE=0 from /etc/profile
sed -i '/HISTFILESIZE=0/d' /etc/profile

# Configure common profile
cat > /etc/profile.d/common_profile.sh << 'EOF'
#!/bin/bash
# Set bash history size and time format
HISTSIZE=10000
HISTFILESIZE=100000
HISTTIMEFORMAT="%Y-%m-%d %T "

PROMPT_COMMAND="history -a"
shopt -s histappend
export HISTFILE=~/.bash_history

unset HISTCONTROL
# Set user prompt
export PS1="\[\e[36;1m\]\u@\[\e[32;1m\]\h:\[\e[31;1m\]\w:> \[\e[0m\]"
# Set alias for command safety
alias cp='cp -i'
alias mv='mv -i'
alias ll='ls -al'

# Set environment variables
export PATH USER HOSTNAME HISTSIZE HISTFILESIZE HISTTIMEFORMAT

EOF
chmod 755 /etc/profile.d/common_profile.sh

# Add common_profile.sh to .bashrc
for user in root sysuser; do
  home_dir=$(eval echo ~$user)
  echo "source /etc/profile.d/common_profile.sh" >> $home_dir/.bashrc
done

# Modify permissions
chown sysuser:sysmgt /home/sysuser/.bashrc