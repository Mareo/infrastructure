resource "gitlab_user_sshkey" "mareo_cardno-11341889" {
  user_id = gitlab_user.users["mareo"].id
  title   = "cardno:11341889"
  key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNwnObkPiK+p6EraNrC0eIn98vaHnPLsTTMw4rKsQM7"
}

resource "gitlab_user_sshkey" "mareo_apollo" {
  user_id = gitlab_user.users["mareo"].id
  title   = "apollo"
  key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6qcdLNMZP8MeytZuPp9THvowbsys6vqHuEVQil0sulFzz2jWJcB0P++q9SDbLHxijRbrfbO2tl4gH/1HXuSAIUm+kipBHqoAcwZstygW/qqR1YTDjZ7wM1zhwsZRbqxkLYspTDLQ3wzhOIM8r8IH64PMPKfwt5G123gGLS2WlPnZh1m5pORjWBcx5xvNU95OMn0twIX5ok3DNNHNpSt4QO8vYAfzEeO/3RZ45gYuovVQkYDRMX72QJR9+nIb+UJp8rdNXFAaI/KBDt4oXjB7tFyDNVvAcfHnlqmJJdA2G5ke4+ftIJsXXhn/8YWlMgjYRgnUNjeBXaZ3D+I3+4pDa0X6NZOySJYWWVrhWoi2WDA7K/xU8qegO2QYkmYHU3iQTacq+jrWsWJrAheukdbXpIbYIzkKgzD7Gu3QA0X8hbMYp8vszba/XMZ7ZfTPRnQVl9LaMIwl0hJfWnqPEnuY4rLfjf9yxeb95Xivcs8tQEgPAVItp6wT23eJwfNHvp08="
}

resource "gitlab_user_sshkey" "mareo_eos" {
  user_id = gitlab_user.users["mareo"].id
  title   = "eos"
  key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRjWonANQ/xE+bAU6e0Wd2s97ONLuHP9EPxdeQTf48NdMOBq/Zyuej8xRd91tHjsF230wMkQemDkSWgEmM9w99yXVt3IOtRizchAQLKEq+3R0eU6gES/gFZ9VL6bNei0jvWAhqNDn7bb/k5FmS+Joy4nsINxmHPBzhJFlcGfENrpUl/lPfWOoldkEjNZ8Wzaxx+OIcvoxsITlOVLu5zD/sRhDS82R6Dr4xPnJxVUxHfmB+ypRTfjA/gBW3JLFxe/GvgpfNpX20OsZPlzyLedW/Km3v3kUFDM5ygAArIAi/LCGohYLF+qkofrj3IM+mxI98ysa8g6SA5jKpC/SA0mZbadUfQJRrFYJp0cJcweMqshqwYG1F4uxm0dv2XTMaoSTn+RixKhIYi9TZK6FWzSZf96tb+n17ZybSv+y+KB1Qa5eJxxaGdFbwO2XAXLtTlhSfPW96AKOSD+d+0N+lJLPOj8HpQiv7+Qq2tUmtNIbelfg7Fzeei9WcsAJvXiHlj5ZOKREsZwe8Z+7gy1XtS57yaq2ogx27vpEYpPqjpX75LSvwxuDBr/5/gEZfDhucLo0LNT9w3mxu6LZCuQB1hNER2IoIADEvizEHyEBguqPYWo7542WJn87nXpy9wwYo7R5Pmv0hVOXCl9NcuEIcZDcvB31cjLLOEf2C546umjMVvw== Marin Hannache (gitlab.mareo.fr)"
}
