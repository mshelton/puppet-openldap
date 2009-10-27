class openldap::client {
  package {"ldap-utils":
    ensure => installed,
  }

  file { 
    "/etc/ldap":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => 755;
    "/etc/ldap/ldap.conf":
      require => Package["ldap-utils"],
      content => template("openldap/ldap.conf.erb");
  }
}
