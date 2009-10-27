class openldap::server {

  debug ("configuring openldap::server with dn '$ldap_base'")

  package {"slapd":
    ensure        => installed,
    responsefile  => "/var/cache/debconf/slapd.preseed",
    require       => File["/var/cache/debconf/slapd.preseed"],
  }
  if defined(Package["ldap-utils"]) { } else {
    package {"ldap-utils": ensure => present, }
  }
  
  service {"slapd":
    ensure  => running,
    require => Package[slapd],
  }

  if ($ldap_ssl_only) {
    $line = 'SLAPD_SERVICES="ldaps:///"'
  } else {
    $line = 'SLAPD_SERVICES="ldap:/// ldaps:/// ldapi:///"'
  }
  line {"listen_locally":
#    line    => 'SLAPD_SERVICES="ldap:/// ldaps:/// ldapi:///"',
    line    => $line,
    file    => "/etc/default/slapd",
    ensure  => present,
    require => Package[slapd],
    notify  => Service[slapd],
  }

  file {
    "/var/cache/debconf/slapd.preseed":
      content => template("openldap/slapd.preseed.erb"),
      mode    => 0600, 
      owner   => root, 
      group   => root;
   "/usr/local/sbin/ldap-backup.sh":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 755,
      source  => "puppet:///openldap/usr/local/sbin/ldap-backup.sh";
    "/var/backups/ldap":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => 750;
  }
  
  file {
    "/etc/ldap/schema":
      ensure => directory,
      mode   => 755,
      owner  => root,
      group  => root,
      require => Package[slapd];
    "/etc/ldap/schema/authldap.schema":
      ensure => present,
      mode   => 644,
      owner  => root,
      group  => root,
      source  => "puppet:///openldap/etc/ldap/schema/authldap.schema",
      require => File["/etc/ldap/schema"];
  }

  cron {"ldap-backup":
    command => "/usr/local/sbin/ldap-backup.sh",
    user    => "root",
    hour    => 2,
    minute  => 0,
    require => File["/var/backups/ldap"],
  } 
}
