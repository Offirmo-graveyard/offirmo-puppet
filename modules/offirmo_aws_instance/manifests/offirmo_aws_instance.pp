
# My classic AWS instance, featuring a few useful packages and tools.

class offirmo_aws_instance
{
	# First, we check if this class is really applied to a compatible system :
	if 0 == 1 # TODO test
	{
		err("It looks like this sytem is not an AWS instance. This class is for AWS instances only.")
	}
	else
	{
		require offirmo_ubuntu
		
		# we finish the "altadmin" alternate admin account
		#user 'altadmin':
		$alt_admin_name    = 'altadmin'
		$alt_admin_home    = "/home/$alt_admin_name"
		$alt_admin_ssh_dir = "$alt_admin_home/.ssh"
		
		# ensure .ssh dir exists
		file
		{
			"$alt_admin_ssh_dir":
				require => [ User[ "$alt_admin_name" ] ],
				ensure  => directory,
				owner   => "$alt_admin_name",
				group   => "$alt_admin_name",
				mode    => '700',
				recurse => true,
				;
		}
		
		# copy login key from ref admin
		$ref_admin_name = 'ubuntu'
		$cred_ssh_file  = 'authorized_keys'
		exec
		{
			"altadmin login credentials":
				unless  => "test -f $alt_admin_ssh_dir/$cred_ssh_file", # any file supposed to be here if wp is correctly installed
				command => "cp /home/$ref_admin_name/.ssh/$cred_ssh_file $alt_admin_ssh_dir/$cred_ssh_file; chown $alt_admin_name:$alt_admin_name $alt_admin_ssh_dir/$cred_ssh_file",
				path    => "/bin:/usr/bin",
				require => [ User[ "$alt_admin_name" ], File[ "$alt_admin_ssh_dir" ] ],
				;
		}
	} # check if AWS instance
}
