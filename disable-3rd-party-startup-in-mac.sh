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
# DBMcLL="${DBK}/Mac$LbLn";
# DBMyLL="${DBK}/My$LbLn";
sS="Disable-3rd-Party-Services:";

# Creating the "~/Desktop/Backup/" folder structure, when it does not exists:
[ -d "~/${DBK}" ] || mkdir -p "~/${DBK}";

# Creating a record (text)-file with a list of all STARTUP items (name & label),
#  into "~/Desktop/Backup/" folder, (before we do steps inside below script-codes):
/bin/launchctl list > "~/${DBK}/${dv}_launchctl-list_begin.txt";
	
	
	# 1ST-STAGE : Using "launchctl" to disable 3rd-Party Auto Startup Items.
	
	while IFS= read -a Ln ; do {
		# We are removing all TAB-chars & whatever before TAB-chars,
		# to get last words after 2nd-TAB, as that is the "Label":
		LNm="${Ln//*$'\x09'/}";
		# If a label is not-starting with "com.apple.", then that is 3rd-Party PLIST,
		# so we will process it further:
		if [[ "${LNm}" != *"com.apple."* ]] ; then {
			# If a label is not-starting with "Label", then its 3rd-Party PLIST,
			# otherwise its the column-header line that shows: "PID  Status  Label":
			if [[ "${LNm}" != "Label" ]] ; then {
				# echo "${LNm}";
				# if the Label is one of below SAFE 3RD-PARTY ITEM, then we will skip stopping it:
				if [[ "$LNm" == "com.avast.Antivirus" ]] || [[ "$LNm" == "com.avast.hub" ]] || \
				 [[ "$LNm" == "com.avast.hub.xpc" ]] || [[ "$LNm" == "com.avast.hub.schedule" ]] || \
				 [[ "$LNm" == "com.avast.uninstall" ]] || [[ "$LNm" == "com.avast.hns" ]] || \
				 [[ "$LNm" == "com.avast.daemon" ]] || [[ "$LNm" == "com.avast.update" ]] || \
				 [[ "$LNm" == "com.avast.submit" ]] || [[ "$LNm" == "com.avast.proxy" ]] || \
				 [[ "$LNm" == "com.avast.service" ]] || [[ "$LNm" == "com.avast.fileshield" ]] || \
				 [[ "$LNm" == "com.avast.securedns" ]] || [[ "$LNm" == "com.avast.api.xpc" ]] || \
				 [[ "$LNm" == "com.avast.init" ]] ; then {
				 	
					echo "${sS} skipped disabling \"${LNm}\"";
					
				};
				else {	# of "if [[ ... ]] ;"
					# Make a record in a file, which will be disabled (temporarily):
					# ...
					
					# Disable it (temporarily) now:
					echo "${sS} attempting to disable \"${LNm}\"";
					sudo /bin/launchctl stop "${LNm}";
					
					# check again, if successfully disabled, or not:
					# ...
					
					# move the PLIST file into a backup folder:
					# ...
				};	# End of "else ..."
				fi;	# END of "if [[ ... ]] ;"
				
				
			};	# End of "if [[ "${LNm}" != "Label" ]] ; then ..."
			fi;	# END of "if [[ "${LNm}" != "Label" ]] ;"
		};	# End of "if [[ "${LNm}" != *"com.apple."* ]] ; then ..."
		else {	# When item is from 2ND-PARTY (aka: Apple), then:
			
		};	# End of "else ..."
		fi;	# END of "if [[ "${LNm}" != *"com.apple."* ]] ;"
	};	# END of "while IFS= read -a Ln ; do"
	done < <(sudo /bin/launchctl list) ;
	
	# NEXT, 2ND-STAGE : checking various folders directly & disabling 3rd-Party Auto Startup Items.
	
	# To find 3rd-Party Auto Startup Items, We are using 5 pairs of Source-&-Destination Directories,
	#  as we need to loop/iterate same set of functions for each directory:
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
				# Looping thru real PLIST files and symlink PLIST files that are inside the Dir/Folder selected in this loop:
				sudo /usr/bin/find "$sD" -not -type d -print0 | while IFS= read -r -d $'\0' plF ; do {
					# for plF in "${sD}"*.plist* ; do {
					# if selected plist file does-not exists then continuing to next loop:
					#   (to overcome error of "For" loop, as it uses given code once, When no plist/match found)
					# [ -e "${sD}$plF" ] || continue;
					# if selected plist file is not-starting with "com.apple..." or
					#   is not in the white-listed items, then its 3rd-party item or risky-2nd-party item, 
					#   so we will disable it (temporarily) & move it into backup:
					if [[ "$plF" != "com.apple."* ]] ; then {
						# getting plist-file's RunAtLoad property's value:
						enbl=`sudo /usr/libexec/PlistBuddy -c 'print RunAtLoad' "${sD}$plF"`;
						# if RunAtLoad (key) has "true" (value), then its active, so we will process it further:						
						if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ; then {
							# as we found an active 3rd-party item, we will increase the counter value:
							dsblCountr=$(( $dsblCountr + 1 ));
							# checking value of Counter for (plist)-items that are eligible for disable+move:
							if [ "$dsblCountr" -gt 1 ] ; then {
								# appending (3rd-party) plist filenames in a record file, as we are disabling+moving these:
								echo "${sD}$plF" >> "${dD}/disabled-plists.txt";
							};
							else {	# of "if [ "$dsblCountr" -gt 1 ] ;"
								if [ "$dsblCountr" -eq 1 ]; then {
									# creating Dst direcory/folder structure in ~/Desktop/Backup/" (when it does not exist)
									[ -d "${dD}" ] || mkdir -p "${dD}";
									# creating a file containing list of all files & sub-folders that are under the sD(source-direcory)
									#  list will also include file property/permission/etc attributes+settings:
									sudo ls -al "$sD" > ${dD}filesFoldersList.txt ;
									# creating a file that will have list of those PLIST filenames which we have disabled/modified,
									#  so that we can restore later.
									echo "${sD}$plF" > "${dD}/disabled-plists.txt";
								};
								fi;
							};	# End of "if [ "$dsblCountr" -gt 1 ] ; ... ; else ..."
							fi;	# END of "if [ "$dsblCountr" -gt 1 ] ;"
							
							# disabling the STRATUP/plist/item, (before moving):
							sudo /bin/launchctl unload "${sD}$plF" ;
							# sudo /bin/launchctl stop <label>
							# sudo /bin/launchctl load -w "${sD}$plF" ;
							# sudo /bin/launchctl start <label> ;
							# sudo launchctl kickstart -k <label>
							
							# again checking if it has disabled or not:
							enbl=`sudo /usr/libexec/PlistBuddy -c 'print RunAtLoad' "${sD}$plF"`;
							# if launchctl could not disable it, then we will use PlistBuddy to manually disable it:
							if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ; then {
								# using PlistBuddy to disable plist file:
								sudo /usr/libexec/PlistBuddy -c 'Set RunAtLoad fasle' "${sD}$plF" ;
								sudo /usr/libexec/PlistBuddy -c 'Save' "${sD}$plF" ;
							};
							fi;	# END of "if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ;"
							
						};
						fi;	# END of "if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ;"
						
						# moving the 3rd-party STARTUP/plist/item, into "~/Desktop/Backup/" folder:
						sudo /bin/mv "${sD}$plF" "${dD}" ;
					};	# End of "if [[ "$plF" !=  *"com.apple."* ]] ; then ..."
					fi;	# END of "if [[ "$plF" !=  *"com.apple."* ]] ;"
					
				};	# End of "while IFS= read -r -d $'\0' plF ; do ..."
				# done;	# END of "for plF in "${sD}*.plist*" ; do ..."
				done;	# END of "find ... | while IFS= read -r -d $'\0' plF ;"
				
				unset dsblCountr plF enbl;
			};
			fi;	# End of "if [ -d "$sD" ] ;"
			
			
		unset sD dD;
	};
	done;	# End of "for L ... ;"

dv=`$dt`;
# dv2=`$dt`;
# [ "$dv" == "$dv2" ] && dv2="${dv2}p";
# Again creating a record (text)-file with a list of all STARTUP items (name & label),
#  into "~/Desktop/Backup/" folder, (after we've done steps inside above script-codes):
# /bin/launchctl list > "~/${DBK}/${dv2}_launchctl-list.txt";
/bin/launchctl list > "~/${DBK}/${dv}_launchctl-list_end.txt";

unset LNm Ln;
unset dt dv LL DBK LbLn;
# unset dv2 DBMacLL DBMyLL;
