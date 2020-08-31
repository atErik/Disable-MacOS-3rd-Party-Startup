#!/bin/bash
# Copyright 2020 atErik <aterik at ashfolk dot com>. Released under: GPLv3.0, AND, it Must-Not-Be Used To Destroy/Kill,Harm (or Steal-from) Human/Community,Earth,etc.
# Disable-MacOS-3rd-Party-Startup-Software with this bash/zsh script.
#
dt="/bin/date +'%Y-%m-%d_%H-%M-%S'";
dv=`$dt`;
LL="Library/Launch";
DBK="Desktop/Backup";
DBMcLL="${DBK}/MacLibraryLaunch";
DBMyLL="${DBK}/MyLibraryLaunch";

# Creating the "~/Desktop/Backup/" folder structure, when it does not exists:
[ -d "~/${DBK}" ] || mkdir -p "~/${DBK}";

# Creating a record (text)-file with a list of all STARTUP items (name & label), into "~/Desktop/Backup/" folder:
/bin/launchctl list > "~/${DBK}/launchctl-list_${dv}.txt";
	
	# We are using 5 pairs of Source-&-Destination Directories, to loop/iterate same functions for each directory:
	for d in 1 2 3 4 5 ; do { 
		case "$d" in 
		#   Source:                Destination:
		(1) sD="/${LL}Agents/"; dD="~/${DBMcLL}Agents/"; ;; 
		(2) sD="/${LL}Daemons/"; dD="~/${DBMcLL}Daemons/"; ;; 
		(3) sD="~/${LL}Agents/"; dD="~/${DBMyLL}Agents/"; ;; 
		(4) sD="~/${LL}Daemons/"; dD="~/${DBMyLL}Daemons/"; ;; 
		(5) sD="/Library/StartUpItems/"; dD="~/${DBK}/MyMacStartUpItems/"; ;; 
		esac;
			# if the directory (selected in this loop) already exists, then processing items inside it:
			if [ -d "$sD" ] ; then {
				dsblCntr=0;
				# Loading all PLIST files for the Dir/Folder in this loop:
				for f in "${sD}*.plist*" ; do { 
					# if selected plist file does-not exists then continuing to next loop: 
					[ -e "${sD}$f" ] || continue;
					# if selected plist file is not-starting with "com.apple..." or
					#   is not in the white-list items, then its 3rd-party item, 
					#   so we will disable it & move it into backup:
					if [ "$f" does-not begin with "com.apple..." ] ; then {
						# getting plist-file's RunAtLoad property's value:
						enbl=`sudo /usr/libexec/PlistBuddy -c 'print RunAtLoad' "${sD}$f"`;
						# if RunAtLoad (key) has "true" (value), then its active, so we will process it further:						
						if [ "`echo \"$enbl\" | tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ; then {
							# as we found an active 3rd-party item, we will increase the counter value:
							dsblCntr=$(( $dsblCntr + 1 ));
							# creating a record file with 3rd-party plist filenames in it, as we will disable those:
							if [ "$dsblCntr" -gt 1 ] ; then { echo "${sD}$f" >> "${dD}/disabled-plists.txt" ; };
							else {
							  if [ "$dsblCntr" -eq 1 ]; then {
									# creating direcory/folder structure in ~/Desktop/Backup/"
									mkdir -p "${dD}";
									# creating a file containing list of all files & sub-folders under the sD(source-direcory)
									#  list will also include file property/permission/etc attributes+settings:
                  sudo ls -al "$sD" > ${dD}filesFoldersList_${dv}.txt ;
									# creating a file that will have list of those PLIST filenames which we have disabled/modified,
									#  so that we can restore later.
									echo "${sD}$f" > "${dD}/disabled-plists.txt";
								};
                fi;
							};
							fi;
							# disabling the STRATUP/plist/item:
							sudo /bin/launchctl unload -w "${sD}$f" ;
							# again checking if it has disabled or not:
							enbl=`sudo /usr/libexec/PlistBuddy -c 'print RunAtLoad' "${sD}$f"`;
							# if launchctl could not disable it, then we will use PlistBuddy to disable it:
							if [ "`echo \"$enbl\" | tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ; then {
								# using PlistBuddy to disable plist file:
								sudo /usr/libexec/PlistBuddy -c 'Set RunAtLoad fasle' "${sD}$f" ;
								sudo /usr/libexec/PlistBuddy -c 'Save' "${sD}$f" ;
							};
							fi;
							
						};
						fi;
						# moving the 3rd-party STARTUP/plist/item, into "~/Desktop/Backup/" folder:
						sudo mv "${sD}${f}" "${dD}" ; 
					};
					fi;
				};
				done; 
			}; fi;
			
	};
	done;
	
	unset d sD dD dt dv LL DBK DBMLL;
	
