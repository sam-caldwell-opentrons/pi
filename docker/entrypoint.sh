#!/bin/bash -e
# Raspberry Probe Image Builder Entrypoint script
# (c) 2021 Opentrons, Inc.  <samuel.caldwell@opentrons.com>
#
/usr/bin/binfmt --install all

echo running "${PACKER}" "${@}"
exec "${PACKER}" "${@}"
