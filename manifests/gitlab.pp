# Configure a gitlab server (gitlab.domain.tld)
node /gitlab_server/ {

  stage { 'first': before => Stage['main'] }
  stage { 'last': require => Stage['main'] }

  $gitlab_dbname  = 'gitlab_prod'
  $gitlab_dbuser  = 'labu'
  $gitlab_dbpwd   = 'labpass'


  class { 'gitlab::apt': stage => first; }

  # git://github.com/puppetlabs/puppetlabs-mysql.git
  class { 'mysql::server': stage => main; }

  mysql::db {
    $gitlab_dbname:
      ensure   => 'present',
      charset  => 'utf8',
      user     => $gitlab_dbuser,
      password => $gitlab_dbpwd,
      host     => 'localhost',
      grant    => ['all'],
      # See http://projects.puppetlabs.com/issues/17802 (thanks Elliot)
      require  => Class['mysql::config'],
  }

  class {
    'gitlab':
      stage             => last,
      git_user          => 'git',
      git_home          => '/home/git',
      git_email         => 'notifs@foobar.fr',
      git_comment       => 'GitLab',
      # Setup gitlab sources and branch (default to GIT proto)
      gitlab_sources    => 'https://github.com/gitlabhq/gitlabhq.git',
      gitlab_branch     => '5-1-stable',
      gitlab_domain     => 'gitlab.localdomain.local',
      gitlab_dbtype     => 'mysql',
      gitlab_dbname     => $gitlab_dbname,
      gitlab_dbuser     => $gitlab_dbuser,
      gitlab_dbpwd      => $gitlab_dbpwd,
      ldap_enabled      => false,
  }
}
