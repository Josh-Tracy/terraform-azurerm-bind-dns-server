#!/usr/bin/env bash
set -euo pipefail

determine_os_distro() {
  local os_distro_name=$(grep "^NAME=" /etc/os-release | cut -d"\"" -f2)

  case "$os_distro_name" in 
    "Ubuntu"*)
      os_distro="ubuntu"
      ;;
    "CentOS Linux"*)
      os_distro="centos"
      ;;
    "Red Hat"*)
      os_distro="rhel"
      ;;
    *)
      echo "[ERROR] '$os_distro_name' is an unsupported Linux OS distro."
      exit_script 1
  esac

  echo "$os_distro"
}

install_bind() {
  local os_distro="$1"
  
  if [[ -n "$(named -v)" ]]; then
    echo "[INFO] Detected 'bind' is already installed. Skipping."
  else
    if [[ "$os_distro" == "ubuntu" ]]; then
      echo "[INFO] Installing bind9 for Ubuntu (Focal)."
      apt-get install -y bind9
    fi
  fi
    echo "[INFO] bind9 installed successfully. Enabled by default"
}

exit_script() { 
  if [[ "$1" == 0 ]]; then
    echo "[INFO] bind user_data script finished successfully!"
  else
    echo "[ERROR] bind user_data script finished with error code $1."
  fi
  
  exit "$1"
}

main() {
  echo "[INFO] Beginning bind user_data script."
  OS_DISTRO=$(determine_os_distro)
  echo "[INFO] Detected OS distro is '$OS_DISTRO'."
  install_bind "$OS_DISTRO"

# generate named.conf.options file
echo "[INFO] Generating /etc/bind/named.conf.options file."
cat > /etc/bind/named.conf.options << EOF

options {
    directory "/var/cache/bind";
    dnssec-validation auto;
    listen-on-v6 { any; };

    listen-on port 53 {
    ${listen_on_cidrs};
};

    allow-query { any; };

    forwarders {
    ${forwarders};
};  
};
 
EOF

# generate named.conf.local file
echo "[INFO] Generating /etc/bind/named.conf.local file."
cat > /etc/bind/named.conf.local << EOS

zone "${dns_zone}" {
type master;
file "/etc/bind/${dns_zone}";
};

EOS

# generate ${dns_zone} file
echo "[INFO] Generating /etc/bind/${dns_zone} file."
touch /etc/bind/${dns_zone}
cat > /etc/bind/${dns_zone} << EOD

@       IN      SOA     ${dns_hostname}.${dns_zone}. ${soa_username}.${dns_zone}. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ${dns_hostname}.${dns_zone}.
ns       IN      A       ${dns_server_private_ip}

; Nameserver
${dns_hostname}.${dns_zone}.   IN     A       ${dns_server_private_ip}

; Other Hosts
${a_record_servername}.        IN      A      ${a_record_ip_address}

EOD

echo "[INFO] Checking configuration syntax"
named-checkconf
  
echo "[INFO] Restarting bind9.service"
systemctl restart bind9

exit_script 0

}

main "$@"