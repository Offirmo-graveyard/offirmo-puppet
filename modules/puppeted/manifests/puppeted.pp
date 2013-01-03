
# This module offers mainly some puppet debug utilities.
# This module expects the declaration of the following stages : first, bootsrap, apt, main, last



# A defined type containing a notification about the current stage.
# Used for run stages debugging, see below.
define puppet_stage_report($report_id)
{
	notify { "report-puppet-stage-$report_id":
		message => "
*******
Hello from stage \"$::stage\"
*******
";
	}
}
# Those classes are used to insert notifications about current puppet run stage. (see doc about run stages)
# Since stages declaration can only be applied to classes, and since a class can only be used once,
# we must define a class for each stage.
# See below for the use of those classes.
class puppet-stage-reporter-first     { puppet_stage_report { puppet_stage_report_first:     report_id => 'first' } }
class puppet-stage-reporter-apt       { puppet_stage_report { puppet_stage_report_apt:       report_id => 'apt' } }
class puppet-stage-reporter-main      { puppet_stage_report { puppet_stage_report_main:      report_id => 'main' } }
class puppet-stage-reporter-last      { puppet_stage_report { puppet_stage_report_last:      report_id => 'last' } }

# puppet debug utilities
class puppeted
{
	notify
	{
		hello-world:
			message => "Hello world !";
	}
	
	notify
	{
		debug-infos:
			message => "
Debug infos :
- current stage = $stage
- facts : (you can see them all by typing 'facter' in a console)
  - operatingsystem = $::operatingsystem $::lsbdistrelease '$::lsbdistcodename'
  - fqdn = $::fqdn (hostname = $::hostname, domain = $::domain)
  - $::ipaddress
";
	}
	
	# Display a notification for each stage.
	# Of course, we cannot guaranty that the notification will be displayed at the beginning of the stage.
	class
	{
		puppet-stage-reporter-first:
			stage => first;
		puppet-stage-reporter-apt:
			stage => apt;
		puppet-stage-reporter-main:
			stage => main;
		puppet-stage-reporter-last:
			stage => last;
	}
	
} # class apt-powered
