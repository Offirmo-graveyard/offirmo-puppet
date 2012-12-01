
class ssh::user_keys($username, $source)
{
	$user_home    = "/home/$username"
	$user_ssh_dir = "$user_home/.ssh"
	
	file
	{
		"$user_home":
			owner   => "$username",
			group   => "$username",
			ensure  => directory,
			require => User["$username"];
		"$user_ssh_dir":
			owner   => "$username",
			group   => "$username",
			mode    => 700,
			ensure  => directory,
			require => File["$user_home"];
		"$user_ssh_dir/id_rsa":
			owner   => "$username",
			group   => "$username",
			mode    => 600,
			source  => "$source/id_rsa",
			backup  => '.puppet-bak',
			require => File["$user_ssh_dir"];
		"$user_ssh_dir/id_rsa.pub":
			owner   => "$username",
			group   => "$username",
			mode    => 644,
			source  => "$source/id_rsa.pub",
			backup  => '.puppet-bak',
			require => File["$user_ssh_dir"];
	}
	
}
