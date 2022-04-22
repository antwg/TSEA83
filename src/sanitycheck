#!/bin/bash

if sed 's/--.*//' < "$1" | grep -n \'event
then
    echo "ERROR in $1: Du använder nyckelordet 'event. Om du vill kolla efter en klockflank bör rising_edge användas istället. Om du vill använda 'event till något annat i syntetiserbar kod bör du antagligen tänka om."
    exit 1
fi


