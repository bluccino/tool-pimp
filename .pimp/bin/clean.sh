#!/bin/bash
# clean.sh: clean workspace
# Copyright (c) 2024 Bluenetics GmbH
# SPDX-License-Identifier: Apache-2.0

#===============================================================================
# claen -?;  clean --help   # show usage
#===============================================================================

   if [ "$*" == "-?" ] || [ "$*" == "--help" ] || [ "$*" == "--?" ]; then
      ec -g "usage (version `clean --version`)"
      echo  '  clean              # clean workspace (deps, @pimp, .west)'
      echo  '  clean -?           # show usage'
      echo  '  clean --version    # print version'
      return 0 2>/dev/null || exit 0  # safe return/exit
   fi

#===============================================================================
# pimp --version   # print version
#===============================================================================

   if [ "$*" == "--version" ] || [ "$*" == "--v" ]; then
      echo "1.0.0";
      return 0 2>/dev/null || exit 0  # safe return/exit
   fi

#===============================================================================
# clean   # standard command line
#===============================================================================

   if [ "$*" == "" ]; then
      _ROOT=$(dirname `pimp --path .pimp`)

      if [ -d $_ROOT/deps ]; then
	       read -p "delete deps directory [Y/n] ($_ROOT/deps)?" _ANS
				 if [ "$_ANS" == "Y" ] || [ "$_ANS" == "y" ] || [ "$_ANS" == "" ]; then
            ec -g "=== remove $_ROOT/deps"
				    rm -rf $_ROOT/deps
				 fi
      fi

      if [ -d $_ROOT/.west ]; then
         read -p "delete .west directory [Y/n] ($_ROOT/.west)?" _ANS
			   if [ "$_ANS" == "Y" ] || [ "$_ANS" == "y" ] || [ "$_ANS" == "" ]; then
            ec -g "=== remove $_ROOT/.west"
			      rm -rf $_ROOT/.west
			   fi
      fi

      if [ -d $_ROOT/@pimp ]; then
         read -p "delete virtual enviroment directory @pimp [Y/n] ($_ROOT/@pimp)?" _ANS
			   if [ "$_ANS" == "Y" ] || [ "$_ANS" == "y" ] || [ "$_ANS" == "" ]; then
            ec -g "=== deactivate and remove $_ROOT/@pimp"
            deactivate
			      rm -rf $_ROOT/@pimp
			   fi
			fi

      rm -rf $_ROOT/test/build

      unset _ANS
      unset _ROOT
      return 0 2>/dev/null || exit 0  # safe return/exit
   fi

#===============================================================================
# cannot deal with anything else ...
#===============================================================================

   ec -r "bad command line: pimp $*"
   clean -?
   exit 1
