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
      exit 0
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
      PIMP=`pimp --path .pimp`
      ROOT=$(dirname $PIMP)

      read -p "delete deps directory [Y/n] ($ROOT/deps)?" ANS
			if [ "$ANS" == "Y" ] || [ "$ANS" == "y" ] || [ "$ANS" == "" ]; then
			   rm -rf $ROOT/deps
			fi

      read -p "delete virtual enviroment directory @pimp [Y/n] ($ROOT/@pimp)?" ANS
			if [ "$ANS" == "Y" ] || [ "$ANS" == "y" ] || [ "$ANS" == "" ]; then
			   rm -rf $ROOT/@pimp
         deactivate
			fi

      read -p "delete .west directory [Y/n] ($ROOT/.west)?" ANS
			if [ "$ANS" == "Y" ] || [ "$ANS" == "y" ] || [ "$ANS" == "" ]; then
			   rm -rf $ROOT/.west
			fi

      exit 0
   fi

#===============================================================================
# cannot deal with anything else ...
#===============================================================================

   ec -r "bad command line: pimp $*"
   clean -?
   exit 1
