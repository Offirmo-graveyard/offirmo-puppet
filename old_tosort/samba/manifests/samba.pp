

class samba::params
{
	$conf_dir = '/etc/samba/'
}

class samba::common
{
	
}

class samba::server
{
	require samba::common
	
}

class samba::client
{
	require samba::common
	
}

define samba::server::serving_share_for($folder, $user, $comment)
{
	require samba::server
	
	$content = "
[$name]
   path = $folder
   available = yes
   browseable = yes
   public = no
   writable = yes
   valid users = $user
   create mask = 0755
   directory mask = 0755
   comment = $comment
"
	file
	{
		
	}

}
