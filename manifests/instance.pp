define tomcat::instance (
  $basedir          = $::tomcat::basedir,
  $bind_address     = $::tomcat::bind_address,
  $check_port       = $::tomcat::check_port,
  $config           = $::tomcat::config,
  $cpu_affinity     = $::tomcat::cpu_affinity,
  $dependencies     = $::tomcat::dependencies,
  $down             = $::tomcat::down,
  $files            = $::tomcat::files,
  $filestore        = $::tomcat::filestore,
  $gclog_enabled    = $::tomcat::gclog_enabled,
  $gclog_numfiles   = $::tomcat::gclog_numfiles,
  $gclog_filesize   = $::tomcat::gclog_filesize,
  $group            = $::tomcat::group,
  $java_home        = $::tomcat::java_home,
  $java_opts        = $::tomcat::java_opts,
  $jolokia          = $::tomcat::jolokia,
  $jolokia_address  = $::tomcat::jolokia_address,
  $jolokia_cron     = $::tomcat::jolokia_cron,
  $jolokia_port     = $::tomcat::jolokia_port,
  $jolokia_version  = $::tomcat::jolokia_version,
  $localhost        = $::tomcat::localhost,
  $logdir           = $::tomcat::logdir,
  $max_mem          = $::tomcat::max_mem,
  $min_mem          = $::tomcat::min_mem,
  $mode             = $::tomcat::mode,
  $remove_docs      = $::tomcat::remove_docs,
  $remove_examples  = $::tomcat::remove_examples,
  $templates        = $::tomcat::templates,
  $ulimit_nofile    = $::tomcat::ulimit_nofile,
  $version          = $::tomcat::version,
  $workspace        = $::tomcat::workspace,
) {
  if ! $version {
    fail( 'tomcat version MUST be set' )
  }
  $user        = $title
  $product     = 'apache-tomcat'
  $product_dir = "${basedir}/${product}-${version}"

  if ! defined(File[$workspace]) {
    file { $workspace:
      ensure => directory,
    }
  }

  include runit
  if ! defined(Runit::User[$user]) {
    runit::user { $user:
      basedir => $basedir,
      group   => $group,
    }
  }

  tomcat::install { "${user}-${product}":
    basedir         => $basedir,
    filestore       => $filestore,
    group           => $group,
    java_home       => $java_home,
    jolokia         => $jolokia,
    jolokia_address => $jolokia_address,
    jolokia_cron    => $jolokia_cron,
    jolokia_port    => $jolokia_port,
    jolokia_version => $jolokia_version,
    logdir          => $logdir,
    ulimit_nofile   => $ulimit_nofile,
    user            => $user,
    version         => $version,
    workspace       => $workspace,
  }

  if ! $templates['conf/server.xml'] {
    file { "${product_dir}/conf/server.xml":
      ensure   => present,
      owner    => $user,
      group    => $group,
      mode     => $mode,
      content  => template('tomcat/server.xml.erb'),
      require  => Exec["tomcat-unpack-${user}"],
    }
  }

  if ! $templates['conf/logging.properties'] {
    file { "${product_dir}/conf/logging.properties":
      ensure   => present,
      owner    => $user,
      group    => $group,
      mode     => $mode,
      content  => template('tomcat/logging.properties.erb'),
      require  => Exec["tomcat-unpack-${user}"],
    }
  }

  create_resources_with_prefix( 'tomcat::file', $files,
    {
      group       => $group,
      mode        => $mode,
      product_dir => $product_dir,
      user        => $user,
    },
    "${product_dir}/",
  )

  create_resources_with_prefix( 'tomcat::template', $templates,
    {
      basedir         => $basedir,
      bind_address    => $bind_address,
      check_port      => $check_port,
      config          => $config,
      cpu_affinity    => $cpu_affinity,
      dependencies    => $dependencies,
      down            => $down,
      filestore       => $filestore,
      group           => $group,
      java_home       => $java_home,
      java_opts       => $java_opts,
      jolokia         => $jolokia,
      jolokia_address => $jolokia_address,
      jolokia_cron    => $jolokia_cron,
      jolokia_port    => $jolokia_port,
      jolokia_version => $jolokia_version,
      localhost       => $localhost,
      logdir          => $logdir,
      max_mem         => $max_mem,
      min_mem         => $min_mem,
      mode            => $mode,
      product_dir     => $product_dir,
      ulimit_nofile   => $ulimit_nofile,
      user            => $user,
      version         => $version,
      workspace       => $workspace,
    },
    "${product_dir}/",
  )

  if $remove_docs {
    file { "${product_dir}/webapps/docs":
      ensure  => absent,
      recurse => true,
      force   => true,
      purge   => true,
      backup  => false,
      require => Exec["tomcat-unpack-${user}"],
    }
  }

  if $remove_examples {
    file { "${product_dir}/webapps/examples":
      ensure  => absent,
      recurse => true,
      force   => true,
      purge   => true,
      backup  => false,
      require => Exec["tomcat-unpack-${user}"],
    }
  }

  tomcat::service { "${user}-${product}":
    basedir         => $basedir,
    bind_address    => $bind_address,
    check_port      => $check_port,
    dependencies    => $dependencies,
    gclog_enabled   => $gclog_enabled,
    gclog_numfiles  => $gclog_numfiles,
    gclog_filesize  => $gclog_filesize,
    localhost       => $localhost,
    logdir          => $logdir,
    product         => $product,
    user            => $user,
    filestore       => $filestore,
    group           => $group,
    version         => $version,
    java_home       => $java_home,
    java_opts       => $java_opts,
    jolokia         => $jolokia,
    jolokia_address => $jolokia_address,
    jolokia_cron    => $jolokia_cron,
    jolokia_port    => $jolokia_port,
    jolokia_version => $jolokia_version,
    config          => $config,
    cpu_affinity    => $cpu_affinity,
    min_mem         => $min_mem,
    max_mem         => $max_mem,
    down            => $down,
    ulimit_nofile   => $ulimit_nofile,
  }

}
