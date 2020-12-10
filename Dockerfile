# Utilize the image from download.yaml
# This is because we need to download the latest image from Red Hat. Current
# implementation for doing ARG based FROM instructions require replacing
# the FROM with an already existing image (i.e. one we've previously built).
# This prevents us from retrieving the latest image from Red Hat.
FROM ubi/ubi8:8.3


COPY scripts /dsop-fix/

COPY ironbank.repo /etc/yum.repos.d/ironbank.repo

COPY banner/issue /etc/

# Be careful when adding packages because this will ultimately be built on a licensed RHEL host,
# which enables full RHEL repositories and could allow for installation of packages that would
# violate Red Hat license agreement when running the container on a non-RHEL licensed host.
# See the following link for more details:
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/building_running_and_managing_containers/index/#add_software_to_a_running_ubi_container
RUN echo Update packages and install DISA STIG fixes && \
    # Disable all repositories (to limit RHEL host repositories) and only use official UBI repositories
    sed -i "s/enabled=1/enabled=0/" /etc/dnf/plugins/subscription-manager.conf && \
    rm -f /etc/yum.repos.d/ubi.repo && \
    dnf repolist && \
    dnf update -y && \
    # Do not use loops to iterate through shell scripts, this allows for scripts to fail
    # but the build to still be successful. Be explicit when executing scripts and ensure
    # that all scripts have "set -e" at the top of the bash file!
    /dsop-fix/xccdf_org.ssgproject.content_rule_package_crypto-policies_installed.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_openssl_use_strong_entropy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_configure_kerberos_crypto_policy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_configure_openssl_crypto_policy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_package_sudo_installed.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_ensure_gpgcheck_local_packages.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_disable_ctrlaltdel_burstaction.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_minlen_login_defs.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_no_empty_passwords.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_account_disable_post_pw_expiration.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_max_concurrent_login_sessions.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_umask_etc_bashrc.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_umask_etc_profile.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_umask_etc_csh_cshrc.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_maxclassrepeat.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_dcredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_ocredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_lcredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_maxrepeat.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_ucredit.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_minlen.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_difok.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_unlock_time.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_password_pam_unix_remember.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_interval.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_package_iptables_installed.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_coredump_disable_storage.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_coredump_disable_backtraces.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_disable_users_coredumps.sh && \
    dnf clean all && \
    rm -rf /dsop-fix/ /var/cache/dnf/ /var/tmp/* /tmp/* /var/tmp/.???* /tmp/.???*

ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["/bin/bash"]
