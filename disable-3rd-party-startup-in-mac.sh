#!/bin/bash
# Copyright 2020 atErik <aterik at ashfolk dot com>.
# Released under: GPLv3.0 AND it Must-NOT-Be-Used To Destroy/Kill,Harm (or Steal-from) Human/Community,Earth,etc.
# Disable-MacOS-3rd-Party-Startup software,services,apps,tools,etc with this bash/zsh script.
#
dt="/bin/date +%Y-%m-%d_%H-%M-%S";
dv=`$dt`;
LL="Library/Launch";
LbLn="LibraryLaunch";
DBK="Desktop/Backup";
DBMcLL="${DBK}/Mac$LbLn";
DBMyLL="${DBK}/My$LbLn";

# Creating the "~/Desktop/Backup/" folder structure, when it does not exists:
[ -d "~/${DBK}" ] || mkdir -p "~/${DBK}";

# Creating a record (text)-file with a list of all STARTUP items (name & label),
#  into "~/Desktop/Backup/" folder, (before we do steps inside below script-codes):
/bin/launchctl list > "~/${DBK}/${dv}_launchctl-list_begin.txt";
	
	# We are using 5 pairs of Source-&-Destination Directories, to loop/iterate same functions for each directory:
	for L in 1 2 3 4 5 ; do { 
		# Loading Src & Dst folders, etc:
		case "$L" in 
		#   sD = Source/Src Dir:       dD = Destination/Dst Dir:
		(1) sD="/${LL}Agents/"; dD="~/${DBK}/${dv}_Mac${LbLn}Agents/"; ;; 
		(2) sD="/${LL}Daemons/"; dD="~/${DBK}/${dv}_Mac${LbLn}Daemons/"; ;; 
		(3) sD="~/${LL}Agents/"; dD="~/${DBK}/${dv}_My${LbLn}Agents/"; ;; 
		(4) sD="~/${LL}Daemons/"; dD="~/${DBK}/${dv}_My${LbLn}Daemons/"; ;; 
		(5) sD="/Library/StartUpItems/"; dD="~/${DBK}/${dv}_MacLibraryStartUpItems/"; ;; 
		esac;
		
			# if the Src directory (selected in this loop) exists, then we begin to process items inside it:
			if [ -d "$sD" ] ; then {
				dsblCountr=0;
				# Looping thru each PLIST files that are inside the Dir/Folder selected in this loop:
				for f in "${sD}*.plist*" ; do { 
					# if selected plist file does-not exists then continuing to next loop:
					#   (to overcome error of "For" loop, as it uses given code once, When no plist/match found)
					[ -e "${sD}$f" ] || continue;
					# if selected plist file is not-starting with "com.apple..." or
					#   is not in the white-listed items, then its 3rd-party item or risky-2nd-party item, 
					#   so we will disable it (temporarily) & move it into backup:
					if [ "$f" does-not begin with "com.apple..." ] ; then {  # wait for this line to be developed
						# getting plist-file's RunAtLoad property's value:
						enbl=`sudo /usr/libexec/PlistBuddy -c 'print RunAtLoad' "${sD}$f"`;
						# if RunAtLoad (key) has "true" (value), then its active, so we will process it further:						
						if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ; then {
							# as we found an active 3rd-party item, we will increase the counter value:
							dsblCountr=$(( $dsblCountr + 1 ));
							# checking value of Counter for (plist)-items that are eligible for disable+move:
							if [ "$dsblCountr" -gt 1 ] ; then {
								# appending (3rd-party) plist filenames in a record file, as we are disabling+moving these:
								echo "${sD}$f" >> "${dD}/disabled-plists.txt";
							};
							else {	# of if [ "$dsblCountr" -gt 1 ] ;
								if [ "$dsblCountr" -eq 1 ]; then {
									# creating Dst direcory/folder structure in ~/Desktop/Backup/" (when it does not exist)
									[ -d "${dD}" ] || mkdir -p "${dD}";
									# creating a file containing list of all files & sub-folders that are under the sD(source-direcory)
									#  list will also include file property/permission/etc attributes+settings:
									sudo ls -al "$sD" > ${dD}filesFoldersList.txt ;
									# creating a file that will have list of those PLIST filenames which we have disabled/modified,
									#  so that we can restore later.
									echo "${sD}$f" > "${dD}/disabled-plists.txt";
								};
								fi;
							};
							fi;	# End of if [ "$dsblCountr" -gt 1 ] ;
							# disabling the STRATUP/plist/item, (before moving):
							sudo /bin/launchctl unload -w "${sD}$f" ;
							# again checking if it has disabled or not:
							enbl=`sudo /usr/libexec/PlistBuddy -c 'print RunAtLoad' "${sD}$f"`;
							# if launchctl could not disable it, then we will use PlistBuddy to manually disable it:
							if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ; then {
								# using PlistBuddy to disable plist file:
								sudo /usr/libexec/PlistBuddy -c 'Set RunAtLoad fasle' "${sD}$f" ;
								sudo /usr/libexec/PlistBuddy -c 'Save' "${sD}$f" ;
							};
							fi;	# End of if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ;
							
						};
						fi;	# End of if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ;
						
						# moving the 3rd-party STARTUP/plist/item, into "~/Desktop/Backup/" folder:
						sudo mv "${sD}${f}" "${dD}" ;
					};
					fi;
				};
				done;	# End of for f in "${sD}*.plist*" ;
				unset dsblCountr;
			};
			fi;	# End of if [ -d "$sD" ] ;
			
			
		unset sD dD;
	};
	done;	# End of for L ... ;

dv=`$dt`;
# dv2=`$dt`;
# [ "$dv" == "$dv2" ] && dv2="${dv2}p";
# Again creating a record (text)-file with a list of all STARTUP items (name & label),
#  into "~/Desktop/Backup/" folder, (after we've done steps inside above script-codes):
# /bin/launchctl list > "~/${DBK}/${dv2}_launchctl-list.txt";
/bin/launchctl list > "~/${DBK}/${dv}_launchctl-list_end.txt";

unset dt dv dv2 LL DBK DBMLL LbLn;
	
