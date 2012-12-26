
class cpp_powered::params($owner = 'root')
{
	$cppenv_dir = "/srv/dev/cpp"
	$cppenv_shared_dir = "$cppenv_dir/shared"
	$cppenv_shared_archives_dir = "$cppenv_shared_dir/archives"
	$cppenv_shared_src_dir = "$cppenv_shared_dir/src"
	$cppenv_shared_scripts_dir = "$cppenv_shared_dir/scripts"
	
	$cppenv_defs_file = "cpp_deploy_env.sh"
	$cppenv_compiler_defs_file = "cpp_deploy_env.sh"
	$cppenv_target_defs_file_radix = "cpp_deploy_target_"
	
	$cppenv_owner = $owner
}

# Ensure that the c++ dev tools are present.

## toadd : colormake gdb


class cpp_powered::common($owner = 'root')
{
	class
	{
		'cpp_powered::params':
			owner => $owner,
			;
	}
	
	include 'with_tool::build-essential'
	
	file
	{
		$cpp_powered::params::cppenv_dir:
			ensure => directory,
			owner => $owner,
			;
		$cpp_powered::params::cppenv_shared_dir:
			ensure => directory,
			owner => $owner,
			;
		$cpp_powered::params::cppenv_shared_archives_dir:
			ensure => directory,
			owner => $owner,
			;
		$cpp_powered::params::cppenv_shared_src_dir:
			ensure => directory,
			owner => $owner,
			;
		$cpp_powered::params::cppenv_shared_scripts_dir:
			ensure => directory,
			owner => $owner,
			;
		"${cpp_powered::params::cppenv_shared_scripts_dir}/cpp_deploy.sh":
			source => "puppet:///modules/cpp_powered/cpp_deploy.sh",
			owner => $owner,
			;
		"${cpp_powered::params::cppenv_shared_scripts_dir}/cpp_deploy_target_boost.sh":
			source => "puppet:///modules/cpp_powered/cpp_deploy_target_boost.sh",
			owner => $owner,
			;
		"${cpp_powered::params::cppenv_shared_scripts_dir}/cpp_deploy_target_wt.sh":
			source => "puppet:///modules/cpp_powered/cpp_deploy_target_wt.sh",
			owner => $owner,
			;
		"${cpp_powered::params::cppenv_shared_scripts_dir}/${$cpp_powered::params::cppenv_defs_file}":
			owner => $owner,
			content => "#! /bin/bash

### XXX this file is automatically generated via puppet ! Do not alter it manually !

CPP_DIR=\"$cpp_powered::params::cppenv_dir\"
CPP_SHARED_DIR=\"$cpp_powered::params::cppenv_shared_dir\"
CPP_SHARED_ARCHIVES_DIR=\"$cpp_powered::params::cppenv_shared_archives_dir\"
CPP_SHARED_SRC_DIR=\"$cpp_powered::params::cppenv_shared_src_dir\"
CPP_SHARED_SCRIPTS_DIR=\"$cpp_powered::params::cppenv_shared_scripts_dir\"

CPP_ENV_DEF_FILE=\"$cpp_powered::params::cppenv_compiler_defs_file\"
CPP_TARGET_DEF_FILE_RADIX=\"$cpp_powered::params::cppenv_target_defs_file_radix\"
",
			;
	}
	
	cpp_powered::with_compile_env
	{
		'gccdefault': # this is the "technical name"
			;
	}
	
	class
	{
		'with_tool::cmake':
			;
	}
	
	## basic sources
	file
	{
		"${cpp_powered::params::cppenv_shared_archives_dir}/boost_1_51_0.tar.bz2":
			source => "puppet:///modules/cpp_powered/boost_1_51_0.tar.bz2",
			owner => $owner,
			;
	}
}

class cpp_powered::development($owner = 'root')
{
	class
	{
		'cpp_powered::common':
			owner => $owner,
			;
	}
	#include 'libboost_powered::development'
	
	# package
	# {
		# 'doxygen':
			# ensure => latest; # This packages is not critical, we can use 'latest'
		# [ 'gdb', 'gdbserver' ]:
			# ensure => present; # We match it with a corresponding version on Windows,
			                   # # so we'd rather it no changing version
	# }

} # class cpp powered::development

class cpp_powered($owner = 'root')
{
	class
	{
		'cpp_powered::common':
			owner => $owner,
			;
	}
} # class cpp powered


# shared resource !
define cpp_powered::with_compile_env($compiler_name = 'gcc', $compiler_version = 'default')
{
	include cpp_powered::params

	# REM : $name is the name given to this resource by the caller
	$env_dir  = "${cpp_powered::params::cppenv_dir}/${name}"
	$in_source_build_src_dir  = "$env_dir/in_source_build"
	$builds_dir  = "$env_dir/build"
	$libs_dir    = "$env_dir/lib"
	$bins_dir    = "$env_dir/bin"
	#$scripts_dir = "$env_dir}"
	
	file
	{
		[ "$env_dir", "$in_source_build_src_dir", "$builds_dir", "$libs_dir", "$bins_dir" ]: #, "$scripts_dir" ]:
			ensure => directory,
			owner => "${cpp_powered::params::cppenv_owner}",
			;
	}
	file
	{
		"$env_dir/${$cpp_powered::params::cppenv_compiler_defs_file}":
			owner => "${cpp_powered::params::cppenv_owner}",
			content => "#! /bin/bash

### XXX this file is automatically generated via puppet ! Do not alter it manually !

CPP_ENV_DIR=\"$env_dir\"
CPP_ISBSRC_DIR=\"$in_source_build_src_dir\"
CPP_BUILDS_DIR=\"$builds_dir\"
CPP_LIBS_DIR=\"$libs_dir\"
CPP_BINS_DIR=\"$bins_dir\"
",
			;
	}
}


# shared resource !
define cpp_powered::with_lib_src($lib = 'xxx no lib given xxx', $compile_env_id = 'gccdefault', $version = 'recommended')
{
	include cpp_powered::params
	
	exec
	{
		"ensure-${name}-src":
			command => "/bin/echo hello world from ensure lib src $name for lib $lib version $version in env $compile_env_id !",
			;
	}
}


# shared resource !
define cpp_powered::with_lib($lib = 'xxx no lib given xxx', $compile_env_id = 'gccdefault', $version = 'recommended')
{
	include cpp_powered::params
	
	cpp_powered::with_lib_src
	{
		$name:
			lib => $lib,
			compile_env_id => $compile_env_id,
			version     => $version,
			;
	}
	
	exec
	{
		"ensure-${name}-install":
			command => "/bin/echo hello world from ensure lib $name for lib $lib version $version in env $compile_env_id !",
			;
	}
}

