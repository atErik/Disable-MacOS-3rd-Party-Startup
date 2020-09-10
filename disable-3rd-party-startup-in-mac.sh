#!/bin/bash
# Copyright 2020 atErik <aterik at ashfolk dot com>.
# Released under: GPLv3.0 AND it Must-NOT-Be-Used To Destroy/Kill,Harm (or Steal-from) Human/Community,Earth,etc.
# Disable-MacOS-3rd-Party-Startup software,services,daemons,apps,tools,etc with this bash script.
#
# 
#
dt="/bin/date +%Y-%m-%d_%H-%M-%S";
dv=`$dt`;
dv2="";
LL="Library/Launch";
LbLn="LibraryLaunch";
DBK="Desktop/Backup";
# DBMcLL="${DBK}/Mac$LbLn";
# DBMyLL="${DBK}/My$LbLn";
sS="Disable-3rd-Party-Services:";
iC=0;

m="$sS START. (Begin+CurrentTime: $dv)";
echo "$m";
/usr/bin/syslog -s -l Info "$m";

# Make log-entry when important changes are done, in /var/log/system.log
#   Emergency (level 0) , Alert (level 1), Critical (level 2), Error (level 3), Warning (level 4), Notice (level 5), Info (level 6), Debug (level 7).
#   /usr/bin/syslog -s -l level message...

# $HOME/ = ~/
# Creating the "$HOME/Desktop/Backup/" folder structure, when it does not exists:
[ -d "$HOME/${DBK}" ] || mkdir -p "$HOME/${DBK}" ;

# Creating a record (text)-file with a list of all STARTUP items (name & label),
#  into "$HOME/Desktop/Backup/" folder, (before we do steps inside below script-codes):
dv2=`$dt`;
m="$sS Saving \"launchctl list\" output into \"$HOME/${DBK}/${dv}_launchctl-list_begin.txt\"";
echo "$m ($dv2)";
/usr/bin/syslog -s -l Info "$m";
sudo /bin/launchctl list > "$HOME/${DBK}/${dv}_launchctl-list_begin.txt" ;


plF="";
enbl="";
sD="";
dD="";
	
	
	# 1ST-STAGE : Using "launchctl" to disable 3rd-Party Auto Startup Items.
	
	dv2=`$dt`;
	m="$sS begin processing of \"launchctl list\"";
	echo "$m ($dv2)";
	/usr/bin/syslog -s -l Info "$m";
	
	while IFS= read -a Ln ; do {
		# We are removing all TAB-chars & whatever before TAB-chars,
		# to get last words after 2nd-TAB, as that is the "Label":
		LNm="${Ln//*$'\x09'/}";
		# If a label is not-starting with "com.apple.", then that is 3rd-Party PLIST,
		# so we will process it further:
		if [[ "${LNm}" != *"com.apple."* ]] ; then {
			# If a label is not-starting with "Label", then its 3rd-Party PLIST,
			# otherwise its the column-header line that shows: "PID  Status  Label":
			if [ "${LNm}" != "Label" ] ; then {
				# echo "${LNm}";
				# if the Label is one of below SAFE 3RD-PARTY ITEM, then we will skip stopping it:
				if [ "$LNm" == "com.avast.Antivirus" ] || [ "$LNm" == "com.avast.hub" ] || \
				 [ "$LNm" == "com.avast.hub.xpc" ] || [ "$LNm" == "com.avast.hub.schedule" ] || \
				 [ "$LNm" == "com.avast.uninstall" ] || [ "$LNm" == "com.avast.hns" ] || \
				 [ "$LNm" == "com.avast.daemon" ] || [ "$LNm" == "com.avast.update" ] || \
				 [ "$LNm" == "com.avast.submit" ] || [ "$LNm" == "com.avast.proxy" ] || \
				 [ "$LNm" == "com.avast.service" ] || [ "$LNm" == "com.avast.fileshield" ] || \
				 [ "$LNm" == "com.avast.securedns" ] || [ "$LNm" == "com.avast.api.xpc" ] || \
				 [ "$LNm" == "com.avast.init" ] ; then {
					
					m="$sS skipped disabling 3rd-party item \"${LNm}\", (as its considered to be safe)";
					echo "$m";
					/usr/bin/syslog -s -l Info "$m";
					
				};
				else {	# of "if [ ... ] ... ;"
					# increasing iteration/loop counter:
					iC=$(( $iC + 1 ));
					
					if [ "$iC" -gt "1" ] ; then
						m="$sS Saving/appending \"${LNm}\" into \"${dD}/disabled-LaunchCtlList.txt\"";
						echo "$m";
						/usr/bin/syslog -s -l Info "$m";
						echo "${LNm}" >> "${dD}/disabled-LaunchCtlList.txt" ;
					else
						if [ "$iC" -eq 1 ] ; then {
							# Make a backup folder, and make a record into a file, which will be disabled (temporarily):
							dD="$HOME/${DBK}/${dv}_MacLaunchCtlList/";
							[ -d "${dD}" ] || mkdir -p "$dD" ;
							
							m="$sS Saving \"${LNm}\" into \"${dD}/disabled-LaunchCtlList.txt\"";
							echo "$m";
							/usr/bin/syslog -s -l Info "$m";
							echo "${LNm}" > "${dD}/disabled-LaunchCtlList.txt" ;
						fi;
					fi;
					
					# Disable it (temporarily) now:
					m="$sS attempting to disable 3rd-party item \"${LNm}\"";
					echo "$m";
					/usr/bin/syslog -s -l Info "$m";
					m="$sS skipped executing command:  \"sudo /bin/launchctl stop \"${LNm}\" ;\"";
					echo "$m";
					/usr/bin/syslog -s -l Info "$m";
					#sudo /bin/launchctl stop "${LNm}" ;
					# check again, if successfully disabled, or not:
					# ...
					
					# move the PLIST file into a backup folder:
					#dD="$HOME/${DBK}/${dv}_MacLaunchCtlList/";
					# moving disabled (3rd-party STARTUP/plist/item), into "$dD" folder:
					#m="$sS skipped executing command:  \"sudo /bin/mv \"${sD}$plF\" \"${dD}\" ;\"";
					#echo "$m";
					#/usr/bin/syslog -s -l Info "$m";
					#sudo /bin/mv "${sD}$plF" "${dD}" ;
					
					
				};	# End of "else ..."
				fi;	# END of "if [ ... ] ... ;"
				
				
			};	# End of "if [ "${LNm}" != "Label" ] ; then ..."
			fi;	# END of "if [ "${LNm}" != "Label" ] ;"
		};	# End of "if [[ "${LNm}" != *"com.apple."* ]] ; then ..."
		else {	# When item is from 2ND-PARTY (aka: Apple), then:
			m="$sS Skipping macOS/Apple (2nd-party) item \"${LNm}\"";
			echo "$m";
			/usr/bin/syslog -s -l Info "$m";
		};	# End of "else ..."
		fi;	# END of "if [[ "${LNm}" != *"com.apple."* ]] ;"
	};	# END of "while IFS= read -a Ln ; do"
	done < <(sudo /bin/launchctl list) ;	# END of Processing "launchctl list" (1st-Stage)
	
	dv2=`$dt`;
	m="$sS done processing of \"launchctl list\"";
	echo "$m ($dv2)";
	/usr/bin/syslog -s -l Info "$m";
	
	iC=0;
	plF="";
	enbl="";
	sD="";
	dD="";
	
	
	# NEXT, 2ND-STAGE : checking various LA/LD/SUI folders directly & disabling 3rd-Party Auto Startup Items.
	
	# To find 3rd-Party Auto Startup Items, We are using 5 pairs of Source-&-Destination Directories,
	#  as we need to loop/iterate same set of functions, for each directory:
	for L in 1 2 3 4 5 6 ; do {
		# Loading Src & Dst folders, etc based on value inside loop VAR "L":
		case "$L" in 
			#   sD = Source/Src Dir:       dD = Destination/Dst Dir:
			(1) sD="/${LL}Agents/"; dD="$HOME/${DBK}/${dv}_Mac${LbLn}Agents/"; ;; 
			(2) sD="/${LL}Daemons/"; dD="$HOME/${DBK}/${dv}_Mac${LbLn}Daemons/"; ;; 
			(3) sD="$HOME/${LL}Agents/"; dD="$HOME/${DBK}/${dv}_My${LbLn}Agents/"; ;; 
			(4) sD="$HOME/${LL}Daemons/"; dD="$HOME/${DBK}/${dv}_My${LbLn}Daemons/"; ;; 
			(5) sD="/Library/StartUpItems/"; dD="$HOME/${DBK}/${dv}_MacLibraryStartUpItems/"; ;; 
			(6) sD="$HOME//Library/StartUpItems/"; dD="$HOME/${DBK}/${dv}_MyLibraryStartUpItems/"; ;; 
		esac;
		
			# if the Src directory (selected in this loop) exists, then we begin to process items inside it:
			if [ -d "$sD" ] ; then {
				iC=0;
				# Looping thru real PLIST files and symlink PLIST files that are inside the Dir/Folder selected in this loop:
				while IFS= read -r -d $'\0' plF ; do {
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
							iC=$(( $iC + 1 ));
							# checking value of Counter for (plist)-items that are eligible for disable+move:
							if [ "$iC" -gt 1 ] ; then {
								# appending (3rd-party) plist filenames in a record file, as we are disabling+moving these:
								m="$sS Saving(appending) \"${sD}$plF\" into \"${dD}/disabled-plists.txt\"";
								echo "$m";
								/usr/bin/syslog -s -l Info "$m";
								echo "${sD}$plF" >> "${dD}/disabled-plists.txt" ;
							};
							else {	# of "if [ "$iC" -gt 1 ] ;"
								if [ "$iC" -eq 1 ] ; then {
									# creating Dst direcory/folder structure in ~/Desktop/Backup/" (when it does not exist)
									[ -d "${dD}" ] || mkdir -p "${dD}" ;
									# creating a file containing list of all files & sub-folders that are under the sD(source-direcory)
									#  list will also include file property/permission/etc attributes+settings:
									m="$sS Saving output of \"ls -al ${sD}\" into \"${dD}filesFoldersList.txt\"";
									echo "$m";
									/usr/bin/syslog -s -l Info "$m";
									sudo ls -al "$sD" > "${dD}filesFoldersList.txt" ;
									# creating a file that will have list of those PLIST filenames which we have disabled/modified,
									#  so that we can restore later.
									m="$sS Saving \"${sD}$plF\" into \"${dD}/disabled-plists.txt\"";
									echo "$m";
									/usr/bin/syslog -s -l Info "$m";
									echo "${sD}$plF" > "${dD}/disabled-plists.txt" ;
								};
								fi;
							};	# End of "else of if [ "$iC" -gt 1 ] ; ... ;"
							fi;	# END of "if [ "$iC" -gt 1 ] ;"
							
							# disabling the STRATUP/plist/item, (before moving):
							m="$sS skipped executing command:  \"sudo /bin/launchctl unload \"${sD}$plF\" ;\"";
							echo "$m";
							/usr/bin/syslog -s -l Info "$m";
							#sudo /bin/launchctl unload "${sD}$plF" ;
							#  sudo /bin/launchctl unload -w swOrDevName.plist ; # stop & disable it, dont start after reboot
							#  sudo /bin/launchctl unload swOrDevName.plist ; # stop now, but start again after reboot
							#  sudo /bin/launchctl load -w swOrDevName.plist ; # start & enable it, & start after reboot
							#  sudo /bin/launchctl load swOrDevName.plist ; # start now, but dont start again after reboot
							#  sudo /bin/launchctl stop <label> ;
							#  sudo /bin/launchctl start <label> ;
							#  sudo launchctl kickstart -k <label> ; # restart
							
							# again checking if it has disabled or not:
							enbl=`sudo /usr/libexec/PlistBuddy -c 'print RunAtLoad' "${sD}$plF"`;
							# if launchctl could not disable it, then we will use PlistBuddy to manually disable it:
							if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ; then {
								# using PlistBuddy to disable plist file:
								m="$sS skipped executing command:  \"sudo /usr/libexec/PlistBuddy -c 'Set RunAtLoad false' \"${sD}$plF\" ;\"";
								echo "$m";
								/usr/bin/syslog -s -l Info "$m";
								#sudo /usr/libexec/PlistBuddy -c 'Set RunAtLoad false' "${sD}$plF" ;
								m="$sS skipped executing command:  \"sudo /usr/libexec/PlistBuddy -c 'Save' \"${sD}$plF\" ;\"";
								echo "$m";
								/usr/bin/syslog -s -l Info "$m";
								#sudo /usr/libexec/PlistBuddy -c 'Save' "${sD}$plF" ;
							};
							fi;	# END of "if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ;"
							
						};
						fi;	# END of "if [ "`echo \"$enbl\" | /usr/bin/tr \"[A-Z]\" \"[a-z]\"`" == "true" ] ;"
						
						# moving the 3rd-party STARTUP/plist/item, into "~/Desktop/Backup/" folder:
						m="$sS skipped executing command:  \"sudo /bin/mv \"${sD}$plF\" \"${dD}\" ;\"";
						echo "$m";
						/usr/bin/syslog -s -l Info "$m";
						#sudo /bin/mv "${sD}$plF" "${dD}" ;
						
						# End of processing non-Apple items, that is, End of processing 3rd-party items.
					};	# End of "if [[ "$plF" !=  *"com.apple."* ]] ; then ..."
					else {
						# Here we will later process some 2nd-Party based apps/tools/items,
						# that may be unsafe/risky/excessive or not-needed or violating Privacy-Rights,etc
					};
					fi;	# END of "if [[ "$plF" !=  *"com.apple."* ]] ;"
					
				};	# End of "while IFS= read -r -d $'\0' plF ; do ..."
				# done;	# END of "for plF in "${sD}*.plist*" ; do ..."
				done < <(sudo /usr/bin/find "$sD" -not -type d -print0);	# END of "find ... | while IFS= read -r -d $'\0' plF ;"
				
				# unset iC plF enbl;  # moving it outside of loop
			};
			fi;	# End of "if [ -d "$sD" ] ;"
			
			# unset sD dD;  # moving it outside of loop
	};
	done;	# End of "for L ... ;" (2nd-Stage)
	
	
	iC=0;
	plF="";
	enbl="";
	sD="";
	dD="";
	dv2=`$dt`;
	m="$sS done processing of sub-folders \"LaunchAgents\",\"LaunchDaemons\",\"StartUpItems\" inside both \"/Library/\" & \"~/Library/\" folders";
	echo "$m ($dv2)";
	/usr/bin/syslog -s -l Info "$m";
	
	
# .... WAIT MORE STAGES ARE GOING TO BE ADDED HERE SOON , AS SOON AS THEY ARE DEVELOPED ...	
	
	
# dv=`$dt`;
dv2=`$dt`;
# [ "$dv" == "$dv2" ] && dv2="${dv2}p";
# Again creating a record (text)-file with a list of all STARTUP items (name & label),
#  into "~/Desktop/Backup/" folder, (after we've done steps inside above script-codes):
# /bin/launchctl list > "~/${DBK}/${dv2}_launchctl-list.txt";
m="$sS Saving \"launchctl list\" output into \"$HOME/${DBK}/${dv}_launchctl-list_end.txt\"";
echo "$m ($dv2)";
/usr/bin/syslog -s -l Info "$m";
sudo /bin/launchctl list > "$HOME/${DBK}/${dv}_launchctl-list_end.txt" ;

dv2=`$dt`;
m="$sS END. (Begin: $dv). (Current-Time: $dv2)";
echo "$m";
/usr/bin/syslog -s -l Info "$m";
unset LNm Ln;
unset dt dv dv2 m iC LL DBK LbLn;
#unset dv2 DBMacLL DBMyLL;

# NOTES:
# to view LOG messages, run cmd:  syslog | grep (wait for this command to be improved soon)
#
#
