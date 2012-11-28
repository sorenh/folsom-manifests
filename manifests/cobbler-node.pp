# A node definition for cobbler
# You will likely also want to change the IP addresses, domain name, and perhaps
# even the proxy address

node /cobbler-node/ inherits "base" {

# The following are node definitions that will allow cobbler to PXE boot the hypervisor OS onto the system (based on the preseed built above)
# You will want to adjust the "title" (maps to system name in cobbler), mac address (this is the PXEboot MAC target), IP (this is a
# static DHCP delivered address for this particular node), domain (added to /etc/resolv.conf for proper function), power address, 
# the same one for power-strip based power control, per-node for IPMI/CIMC/ILO based control, power-ID needs to map to power port or
# service profile name (in UCSM based deployements)

cobbler::node { "control":
 mac => "00:25:B5:00:05:AF",
 ip => "192.168.25.10",
 ### UCS CIMC Details ###
 power_address => "192.168.26.18:org-SUBORGNAME",
 power_user => "admin",
 power_password => "password",
 power_type => "ucs",
 power_id => "SERVICEPROFILENAME-3",
 ### Advanced Users Configuration ###
 profile => "precise-x86_64-auto",
 domain => $::domain_name,
 node_type => "control",
 preseed => "cisco-preseed",
 }


cobbler::node { "compute01":
 mac => "00:25:B5:00:05:8F",
 ip => "192.168.25.21",
 ### UCS CIMC Details ###
 power_address => "192.168.26.18:org-SUBORGNAME",
 power_user => "admin",
 power_password => "password",
 power_type => "ucs",
 power_id => "SERVICEPROFILENAME-4",
 ### Advanced Users Confirgaution ###
 profile => "precise-x86_64-auto",
 domain => $::domain_name,
 node_type => "compute",
 preseed => "cisco-preseed",
 }

cobbler::node { "compute02":
 mac => "00:25:B5:00:05:7F",
 ip => "192.168.25.22",
 ### UCS CIMC Details ###
 power_address => "192.168.26.18:org-SUBORGNAME",
 power_user => "admin",
 power_password => "password",
 power_type => "ucs",
 power_id => "SERVICEPROFILENAME-5",
 ### Advanced Users Confirgaution ###
 profile => "precise-x86_64-auto",
 domain => $::domain_name,
 node_type => "compute",
 preseed => "cisco-preseed",
 }

# Repeat as necessary.

###### Nothing needs to be manually edited from this point ######


####### Preseed File Configuration #######
 cobbler::ubuntu::preseed { "cisco-preseed":
  admin_user => $::admin_user,
  password_crypted => $::password_crypted,
  packages => "openssh-server vim vlan lvm2 ntp puppet",
  ntp_server => $::build_node_fqdn,
late_command => "
sed -e '/logdir/ a pluginsync=true' -i /target/etc/puppet/puppet.conf ; \
sed -e \"/logdir/ a server=$::build_node_fqdn\" -i /target/etc/puppet/puppet.conf ; \
sed -e 's/START=no/START=yes/' -i /target/etc/default/puppet ; \
echo -e \"server $::build_node_fqdn iburst\" > /target/etc/ntp.conf ; \
echo '8021q' >> /target/etc/modules ; \
echo \"# Private Interface\" >> /target/etc/network/interfaces ;\
echo \"auto $::private_interface\" >> /target/etc/network/interfaces ;\
echo \"iface $::private_interface inet manual\" >> /target/etc/network/interfaces ;\
echo \"      vlan-raw-device $::public_interface\" >> /target/etc/network/interfaces ;\
echo \"      up ifconfig $::private_interface 0.0.0.0 up\" >> /target/etc/network/interfaces ; \
echo \" \" >> /target/etc/network/interfaces ; \
true
",
  proxy => "http://${build_node_fqdn}:3142/",
  expert_disk => true,
  diskpart => ["$::node_boot_disk"],
  boot_disk => "$::node_boot_disk",
 }


class { cobbler: 
  node_subnet => $::node_subnet, 
  node_netmask => $::node_netmask,
  node_gateway => $::node_gateway,
  node_dns => $::node_dns,
  ip => $::ip,
  dns_service => $::dns_service,
  dhcp_service => $::dhcp_service,
  dhcp_ip_low => $::dhcp_ip_low,
  dhcp_ip_high => $::dhcp_ip_high, 
  domain_name => $::domain_name,
  proxy => $::cobbler_proxy,
  password_crypted => $::password_crypted,
}

# This will load the Ubuntu Server OS into cobbler
# COE supprts only Ubuntu precise x86_64
 cobbler::ubuntu { "precise":
 }
}
