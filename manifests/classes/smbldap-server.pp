class openldap::smbldap-server inherits openldap::server {

  debug ("configuring openldap::smbldap with dn '$ldap_base'")

  package {"smbldap-tools":
    ensure   => installed,
    require  => [ Package[slapd], Package[samba-common] ],
  }

  case $localsid { 
    '': {
        err("$fqdn: no \$localsid, not installing samba-common")
    }

    default: {
      file {"/etc/smbldap-tools/smbldap.conf":
        content => template("openldap/smbldap.conf.erb"),
        mode    => 0644,
        owner   => root,
        group   => root,
        require => Package[smbldap-tools];
      }
    }
  }

  file {
    "/etc/ldap/schema/samba.schema":
      source  => "puppet:///openldap/etc/ldap/schema/samba.schema",
      mode    => 0644, 
      owner   => root, 
      group   => root,
      require => [Package[slapd], File["/etc/ldap/schema"]],
      notify  => Service[slapd];
    "/etc/smbldap-tools/":
      ensure  => directory, 
      mode    => 0755, 
      owner   => root, 
      group   => root,
      require => Package[smbldap-tools];
    "/etc/smbldap-tools/smbldap_bind.conf":
      content => template("openldap/smbldap_bind.conf.erb"),
      mode    => 0600, 
      owner   => root, 
      group   => root,
      require => Package[smbldap-tools];
  }
}
