#!/bin/bash
# setup (setup script for virtual environment)

echo '=== setup virtual environment ...'
alias ve='source pimp --activate'
alias de=deactivate
alias clean='source clean.sh'
alias ?="bash `pimp --venv`/bin/help"

ec -g 'type ? for help on virtual environment commands'
