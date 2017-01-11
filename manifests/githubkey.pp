#
#
#
class api_builder::githubkey(
    $private_key,
) {

  file { '/root/.ssh' :
    ensure => directory,
    mode   => '0700',
  } ->

  file {'/root/.ssh/id_rsa' :
    content => $::private_key,
    mode    => '0600',
  } ->

  exec { '/usr/bin/ssh-keyscan github.com > /root/.ssh/known_hosts' :
    unless => '/bin/cat /root/.ssh/known_hosts | grep github.com',
  }

}
