#cloud-config
# vim: syntax=yaml
#
# Add yum repository configuration to the system
yum_repos:
    lynis:
        name: CISOfy Software - Lynis
        baseurl: https://packages.cisofy.com/community/lynis/rpm/
        enabled: 1
        gpgkey: https://packages.cisofy.com/keys/cisofy-software-rpms-public.key
        gpgcheck: 1
        priority: 2

write_files:
-   content: |
        \S
        Kernel \r on an \m
        WARNING: This system is restricted to authorized users only.
        Access to the Shell IT network is only permitted to those granted specific authority by the Shell group of companies ('Shell').
        Shell logs and monitors use of its IT equipment and any equipment which is connected via the Shell network in line with the Shell Code of Conduct and applicable laws.
        For further information about permitted use of Shell IT and communications and monitoring please refer to the Shell Code of Conduct and related Privacy Notice- Shell Group Employee, Contractor and Dependents' Personal Data.

    path: /etc/issue
    permissions: '644'

-   content: |
        \S
        Kernel \r on an \m
        WARNING: This system is restricted to authorized users only.
        Access to the Shell IT network is only permitted to those granted specific authority by the Shell group of companies ('Shell').
        Shell logs and monitors use of its IT equipment and any equipment which is connected via the Shell network in line with the Shell Code of Conduct and applicable laws.
        For further information about permitted use of Shell IT and communications and monitoring please refer to the Shell Code of Conduct and related Privacy Notice- Shell Group Employee, Contractor and Dependents' Personal Data.

    path: /etc/issue.net
    permissions: '644'

-   content: |
        fs.suid_dumpable = 0
        # Turn on execshield
        kernel.exec-shield = 1
        # Additional Kernel Hardening
        kernel.dmesg_restrict = 1
        kernel.kptr_restrict = 2
        kernel.randomize_va_space = 2
        kernel.sysrq = 0
        # Disable redirects
        net.ipv4.conf.all.accept_redirects = 0
        # Disable source routing
        net.ipv4.conf.all.accept_source_route = 0
        # Make sure spoofed packets get logged
        net.ipv4.conf.all.log_martians = 1
        net.ipv4.conf.default.log_martians = 1
        # Enable IP spoofing protection
        net.ipv4.conf.all.rp_filter = 1
        # Disable secure redirects
        net.ipv4.conf.all.secure_redirects = 0
        # Disable sending or redirect packets
        net.ipv4.conf.all.send_redirects = 0
        net.ipv4.conf.all.accept_redirects = 0
        # Disable accepting of redirected packets
        net.ipv4.conf.default.accept_redirects = 0
        # Setting default values
        net.ipv4.conf.default.accept_source_route = 0
        net.ipv4.conf.default.rp_filter = 1
        net.ipv4.conf.default.secure_redirects = 0
        net.ipv4.conf.default.send_redirects = 0
        # Ignoring broadcasts request
        net.ipv4.icmp_echo_ignore_broadcasts = 1
        net.ipv4.icmp_ignore_bogus_error_responses = 1
        # Disable IP forwarding
        net.ipv4.ip_forward = 0
        # Hardening against SYN floods
        net.ipv4.tcp_max_syn_backlog = 1280
        net.ipv4.tcp_synack_retries = 5
        net.ipv4.tcp_syncookies = 1
        # prevent attackers from estimating uptime of this machine
        net.ipv4.tcp_timestamps = 0
        # Disable IPv6
        net.ipv6.conf.all.accept_source_route = 0
        net.ipv6.conf.all.disable_ipv6 = 1
        net.ipv6.conf.default.accept_redirects = 0
        net.ipv6.conf.all.accept_redirects = 0
        # Extend the number of connections tracking
        net.netfilter.nf_conntrack_max = 16777216

    path: /ets/sysctl.d/01-security.conf
    permissions: '644'

-   content: |
        #       $OpenBSD: sshd_config,v 1.100 2016/08/15 12:32:04 naddy Exp $
        # This is the sshd server system-wide configuration file.  See
        # sshd_config(5) for more information.
        # This sshd was compiled with PATH=/usr/local/bin:/usr/bin
        # The strategy used for options in the default sshd_config shipped with
        # OpenSSH is to specify options with their default value where
        # possible, but leave them commented.  Uncommented options override the
        # default value.
        # If you want to change the port on a SELinux system, you have to tell
        # SELinux about this change.
        # semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
        #
        #Port 22
        #AddressFamily any
        #ListenAddress 0.0.0.0
        #ListenAddress ::
        HostKey /etc/ssh/ssh_host_rsa_key
        #HostKey /etc/ssh/ssh_host_dsa_key
        HostKey /etc/ssh/ssh_host_ecdsa_key
        HostKey /etc/ssh/ssh_host_ed25519_key
        # Ciphers and keying
        #RekeyLimit default none
        # Logging
        #SyslogFacility AUTH
        SyslogFacility AUTHPRIV
        #LogLevel INFO
        LogLevel VERBOSE
        # Authentication:
        #LoginGraceTime 2m
        #PermitRootLogin yes
        PermitRootLogin no
        #StrictModes yes
        #MaxAuthTries 6
        MaxAuthTries 2
        #MaxSessions 10
        #PubkeyAuthentication yes
        # The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
        # but this is overridden so installations will only check .ssh/authorized_keys
        AuthorizedKeysFile .ssh/authorized_keys
        #AuthorizedPrincipalsFile none
        # For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
        #HostbasedAuthentication no
        # Change to yes if you don't trust ~/.ssh/known_hosts for
        # HostbasedAuthentication
        #IgnoreUserKnownHosts no
        # Don't read the user's ~/.rhosts and ~/.shosts files
        #IgnoreRhosts yes
        # To disable tunneled clear text passwords, change to no here!
        #PasswordAuthentication yes
        #PermitEmptyPasswords no
        PasswordAuthentication no
        # Change to no to disable s/key passwords
        #ChallengeResponseAuthentication yes
        ChallengeResponseAuthentication no
        # Kerberos options
        #KerberosAuthentication no
        #KerberosOrLocalPasswd yes
        #KerberosTicketCleanup yes
        #KerberosGetAFSToken no
        #KerberosUseKuserok yes
        # GSSAPI options
        GSSAPIAuthentication yes
        GSSAPICleanupCredentials no
        #GSSAPIStrictAcceptorCheck yes
        #GSSAPIKeyExchange no
        #GSSAPIEnablek5users no
        # Set this to 'yes' to enable PAM authentication, account processing,
        # and session processing. If this is enabled, PAM authentication will
        # be allowed through the ChallengeResponseAuthentication and
        # PasswordAuthentication.  Depending on your PAM configuration,
        # PAM authentication via ChallengeResponseAuthentication may bypass
        # the setting of "PermitRootLogin without-password".
        # If you just want the PAM account and session checks to run without
        # PAM authentication, then enable this but set PasswordAuthentication
        # and ChallengeResponseAuthentication to 'no'.
        # WARNING: 'UsePAM no' is not supported in Red Hat Enterprise Linux and may cause several
        # problems.
        UsePAM yes
        #AllowAgentForwarding yes
        #AllowTcpForwarding yes
        #GatewayPorts no
        X11Forwarding no
        #X11DisplayOffset 10
        #X11UseLocalhost yes
        #PermitTTY yes
        #PrintMotd yes
        #PrintLastLog yes
        #TCPKeepAlive yes
        TCPKeepAlive no
        #UseLogin no
        #UsePrivilegeSeparation sandbox
        #PermitUserEnvironment no
        #Compression delayed
        Compression no
        ClientAliveInterval 300
        ClientAliveCountMax 2
        #ShowPatchLevel no
        #UseDNS yes
        UseDNS  no
        #PidFile /var/run/sshd.pid
        #MaxStartups 10:30:100
        #PermitTunnel no
        #ChrootDirectory none
        #VersionAddendum none
        # no default banner path
        #Banner none
        # Accept locale-related environment variables
        AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
        AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
        AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
        AcceptEnv XMODIFIERS
        # override default of no subsystems
        Subsystem sftp  /usr/libexec/openssh/sftp-server
        # Example of overriding settings on a per-user basis
        #Match User anoncvs
        #       X11Forwarding no
        #       AllowTcpForwarding no
        #       PermitTTY no
        #       ForceCommand cvs server
        # security settings from https://wiki.mozilla.org/Security/Guidelines/OpenSSH
        Ciphers chacha20-poly1305@openssh.com,aes256-ctr
        KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
        MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
        AuthorizedKeysCommand /opt/aws/bin/eic_run_authorized_keys %u %f
        AuthorizedKeysCommandUser ec2-instance-connect
    path: /etc/ssh/sshd_config
    permissions: '644'


# install package lynis and install amazon-ssm-agent
#
packages:
  - lynis

runcmd:
  - yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  - systemctl enable amazon-ssm-agent
  - systemctl start amazon-ssm-agent
