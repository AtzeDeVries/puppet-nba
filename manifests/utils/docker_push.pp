#
#
class api_builder::utils::docker_push(
    $image_tag,
    $docker_hub_user,
    $docker_hub_pass,
    $trigger,
    $latest = false,
    $local_image_tag = false,
)
{
  $docker_bin = '/usr/bin/docker'


  exec {"login to dockerhub as ${docker_hub_user}" :
    command     => "${docker_bin} login -u ${docker_hub_user} -p ${docker_hub_pass}",
    refreshonly => true,
  }

  #docker image_tag atzedevries/git-update-checker atzedevries/git-update-checker:testimage_tag
  exec {"create image_tag ${image_tag} on ${name} repository" :
    command     => "${docker_bin} image_tag atzedevries/${name}:${name} atzedevries/${name}:${image_tag}",
    refreshonly => true,
    subscribe   => Exec["create ${name}:${image_tag}"],
  }

  exec {"pushing ${name}:${image_tag} to ${docker_hub_user}" :
    command     => "${docker_bin} push atzedevries/${name}:${image_tag}",
    refreshonly => true,
    subscribe   => Exec["create image_tag ${image_tag} on ${name} repository"],
  }

  exec {"create image_tag latest on ${name} repository" :
    command     => "${docker_bin} image_tag atzedevries/${name}:${image_tag} atzedevries/${name}:latest",
    refreshonly => true,
    subscribe   => Exec["create ${name}:${image_tag}"],
  }

  exec {"pushing ${name}:latest to ${docker_hub_user}" :
    command     => "${docker_bin} push atzedevries/${name}:latest",
    refreshonly => true,
    subscribe   => Exec["create image_tag latest on ${image_tag} repository"],
  }

  exec {"logout from dockerhub as ${docker_hub_user}" :
    command     => "${docker_bin} logout",
    refreshonly => true,
    subscribe   => [
      Exec["pushing ${name}:${image_tag} to ${docker_hub_user}"],
      Exec["pushing ${name}:latest to ${docker_hub_user}"]
      ]
  }

  exec {"remove local image ${name}:${image_tag}" :
    command     => "${docker_bin} rmi atzedevries/${name}:${image_tag}",
    refreshonly => true,
    subscribe   => [
      Exec["pushing ${name}:${image_tag} to ${docker_hub_user}"],
      Exec["pushing ${name}:latest to ${docker_hub_user}"]
      ]
  }
}
