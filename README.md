My puppet config
================

This is my puppet config. I use it to setup :
- Web servers (with email capabilities)
  - PHP/MySQL
  - wordpress
  - Wt
- C++ dev machines

The targeted machines are Ubuntu on Amazon web servers or virtualized (VMware / VirtualBox)

I make it public so other puppet users may have a look.

This repo is available at : https://github.com/Offirmo/offirmo-puppet

sudo puppet apply --debug --detailed-exitcodes --verbose manifests/site.pp --modulepath=modules --ignorecache --no-usecacheonfailure

TODO
====
- Better doc ;)
- More...
