#!/bin/bash
#==================================================================================================
#! @file      startup.sh
#! @author    Geon Technologies (geon.tech)
#! @copyright 2022 Geon Technologies, LLC. All rights reserved.
#! @license   GPLv3
#! @brief     bootup script for redhawk-cluster-development
#==================================================================================================

/usr/bin/supervisord -c /etc/supervisord.conf -n &
while true; do sleep 10000; done
