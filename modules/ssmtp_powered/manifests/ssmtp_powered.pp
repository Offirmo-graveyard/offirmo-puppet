
# This class describes ssmtp (simple SMTP) enabled host


# We could write the config files from scratch and ask for every parameters,
# but most likely we'll only use google mail,
# so let's go straight to the point.
class ssmtp_powered($template, $email, $password)
{
	$config_path     = '/etc/ssmtp/ssmtp.conf'
	$revaliases_path = '/etc/ssmtp/revaliases'
	
	package
	{
		[ 'ssmtp' ]:
			ensure => latest; # This packages is not critical, we can use 'latest'
	}
	
	if ($template == 'gmail')
	{
		file
		{
			$config_path:
				# REM : this template needs $email, $password
				content => template("ssmtp_powered/ssmtp.conf.gmail.erb"),
				mode    => '640', # to prevent other accounts from reading the password
				replace => yes, # overwrite the default
				require => [ Package[ 'ssmtp' ] ],
				;
			$revaliases_path:
				# REM : this template needs $email
				content => template("ssmtp_powered/revaliases.gmail.erb"),
				replace => yes, # overwrite the default
				require => [ Package[ 'ssmtp' ] ],
				;
		}
	}
	else
	{
		err("ssmtp : Sorry, I don't know other templates than gmail yet.")
	}
}
