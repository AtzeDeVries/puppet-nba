#
#
#
class api_builder::etl::build(
  $github_private_key = '',
  $github_username    = '',
  $github_password    = '',
  $registry_user        = '',
  $registry_password    = '',
  $registry_email       = 'atze.devries@naturalis.nl'
  ) {

  $repository  = 'https://github.com/naturalis/naturalis_data_api'
  $branch      = 'V2_master'
  $payload_dir = "/opt/etl_builder_${branch}"
  #ensure_packages(['git'])

  $check_name = "git-update-etl-${branch}"
  $check_image = 'atzedevries/git-update-checker'
  $docker_bin = '/usr/bin/docker'
  $check_cmd = "update-check ${repository} ${branch}"

  $buildname = downcase($branch)
  $timestamp = strftime('%Y.%m.%d-%H.%M')
  $image_name = "nba-etl-${buildname}"

  include ::docker

  file { $payload_dir :
      ensure => directory
  }

  exec {"create git update check for etl-${branch}" :
    command => "${docker_bin} create \
                --name ${check_name} \
                -e GITHUB_USER=${github_username} \
                -e GITHUB_PASS='${github_password}' \
                -e SSHKEY='${github_private_key}' \
                ${check_image} ${check_cmd}",
    unless  => "${docker_bin} ps -a | /bin/grep ${check_name}",
  }

  exec { "${repository}:${branch}-etl updated" :
    command => '/bin/echo',
    unless  => "${docker_bin} start -a ${check_name} | /bin/grep Same",
    require => Exec["create git update check for etl-${branch}"],
  }

  exec {"inject sysctl setting for es-etl-${timestamp}" :
    command => '/sbin/sysctl -w vm.max_map_count=262144',
    unless  => '/sbin/sysctl  vm.max_map_count | /bin/grep 262144',
  }

  exec { "run es-etl-${timestamp}" :
    command     => "${docker_bin} run -d -e ES_JAVA_OPTS=\"-Xms512m -Xmx512m\" \
                    --name es-etl-${timestamp} \
                    elasticsearch:2.3.5 \
                    elasticsearch -Des.cluster.name=\"nba-cluster\" ",
    refreshonly => true,
    subscribe   => Exec["${repository}:${branch}-etl updated"],
  }

  exec { "build etl-${branch}"  :
    command     => "${docker_bin} run --rm \
                  -e GITHUB_USER=${github_username} \
                  -e GITHUB_PASS='${github_password}' \
                  -e SSHKEY='${github_private_key}' \
                  -v ${payload_dir}:/payload \
                  --link es-etl-${timestamp}:es \
                  atzedevries/api-builder /build-nba-service.sh ${branch} install-etl-module",
    refreshonly => true,
    subscribe   => Exec["${repository}:${branch}-etl updated"],
    require     => [Exec["run es-etl-${timestamp}"],File[$payload_dir]]
  }

  file {"${payload_dir}/Dockerfile" :
    source  => 'puppet:///modules/api_builder/etl_runner/Dockerfile',
    require => File[$payload_dir],
  }

  exec {"create ${image_name}:${timestamp}" :
    cwd         => $payload_dir,
    command     => "${docker_bin} build -t atzedevries/${image_name}:${timestamp} ./",
    subscribe   => [
      Exec["build etl-${branch}"],
      File["${payload_dir}/Dockerfile"]
      ],
    refreshonly => true,
    require     => File["${payload_dir}/Dockerfile"]
  }

  exec { "cleanup build dir ${payload_dir}" :
    command     => "/bin/rm -rf ${payload_dir}/*",
    refreshonly => true,
    subscribe   => Exec["create ${image_name}:${timestamp}"]
  }

  exec { "cleanup es-etl-${timestamp}" :
    command     => "${docker_bin} rm -f es-etl-${timestamp}",
    refreshonly => true,
    subscribe   => Exec["build etl-${branch}"],
  }

  exec {"push ${registry_user}/${image_name}:${timestamp} to docker hub " :
    command     => "${docker_bin} login -u ${registry_user} -p ${registry_password} &&\
                    ${docker_bin} tag ${registry_user}/${image_name}:${timestamp} ${registry_user}/${image_name}:${timestamp} &&\
                    ${docker_bin} tag ${registry_user}/${image_name}:${timestamp} ${registry_user}/${image_name}:latest && \
                    ${docker_bin} push ${registry_user}/${image_name}:${timestamp} && \
                    ${docker_bin} push ${registry_user}/${image_name}:latest && \
                    ${docker_bin} logout",
    refreshonly => true,
    subscribe   => Exec["create ${image_name}:${timestamp}"],
  }

  exec {"cleanup of build images of ${image_name}:${timestamp}" :
    command     => "${docker_bin} rmi \
                      ${registry_user}/${image_name}:${timestamp} \
                      ${registry_user}/${image_name}:latest",
    refreshonly => true,
    subscribe   => Exec["push ${registry_user}/${image_name}:${timestamp} to docker hub "]
  }


}
