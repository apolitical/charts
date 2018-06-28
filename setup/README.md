Setup Helm
==========

Scripts to setup helm on a given kubernetes context.

_**Important:**_ These scripts must be run from within this directory.

Prerequisites
-------------

You must have `kubectl` and `helm` installed on your system.

setup.sh
--------

Idempotent setup script. If Tiller is already configured within a cluster, running this script will
do nothing.

upgrade.sh
----------

Non-idempotent setup script. This script will not only setup Tiller if it wasn't already there, but
make sure that Tiller is the latest version.
