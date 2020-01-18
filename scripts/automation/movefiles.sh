#!/bin/bash
exec 1> >(logger -s -t $(basename $0)) 2>&1
# https://urbanautomaton.com/blog/2014/09/09/redirecting-bash-script-output-to-syslog/

TARGET=/var/www/html/wp-content/uploads
SOURCE=~ithelper/Site_Files

checkYear () {
	if [[ "$1" =~ .*"2020".* ]]; then
		YEAR=2020
	elif [[ "$1" =~ .*"2019".* ]]; then
		YEAR=2019
	else
		>&2 echo "File $1 did not match; is the year included in the filename and is it 4 digits?"
	fi
}
checkTopic () {
	if [[ "$1" =~ .*"Minute".* ]]; then
		TOPIC=minutes
	elif [[ "$1" =~ .*"Newsletter".* ]]; then
		TOPIC=newsletters
	elif [[ "$1" =~ .*"Document".* ]]; then
		TOPIC=documents
	else
		>&2 echo "File $1 did not match; is the topic included in the name?"
	fi
	
}
checkAssoc () {
	if [[ ""$1"" =~ .*"Berkshire".* ]] || [[ "$1" =~ .*"Berkshire[[:space:]]Landing".* ]]; then
		ASSOC="berkshirelanding"
	elif [[ "$1" =~ .*"Branchlands".* ]] || [[ "$1" =~ .*"Branch[[:space:]]Lands".* ]]; then
		ASSOC=branchlands
	elif [[ "$1" =~ .*"ChathamRidge".* ]] || [[ "$1" =~ .*"Chatham[[:space:]]Ridge".* ]]; then
		ASSOC=chathamridge
	elif [[ "$1" =~ .*"Creekside".* ]] || [[ "$1" =~ .*"VHMCOA".* ]]; then
		ASSOC=creekside
	elif [[ "$1" =~ .*"DruidHill".* ]] || [[ "$1" =~ .*"Druid[[:space:]]Hill".* ]]; then
		ASSOC=druidhill
	elif [[ "$1" =~ .*"HuntingtonVillage".* ]] || [[ "$1" =~ .*"Huntington[[:space:]]Village".* ]]; then
		ASSOC=huntingtonvillage
	elif [[ "$1" =~ .*"LaurelPark".* ]] || [[ "$1" =~ .*"Laurel[[:space:]]Park".* ]]; then
		ASSOC=laurelpark
	elif [[ "$1" =~ .*"RiverRun".* ]] || [[ "$1" =~ .*"River[[:space:]]Run".* ]]; then
		ASSOC=riverrun
	elif [[ "$1" =~ .*"SolomonCourt".* ]] || [[ "$1" =~ .*"Solomon[[:space:]]Court".* ]]; then
		ASSOC=solomoncourt
	elif [[ "$1" =~ .*"SomerChase".* ]] || [[ "$1" =~ .*"Somer[[:space:]]Chase".* ]]; then
		ASSOC=somerchase
	elif [[ "$1" =~ .*"VillageHomesIII".* ]] || [[ "$1" =~ .*"Village[[:space:]]Homes[[:space:]]III".* ]]; then
		ASSOC=villagehomesiii
	elif [[ "$1" =~ .*"VillageHomeIV".* ]] || [[ "$1" =~ .*"Village[[:space:]]Homes[[:space:]]IV".* ]]; then 	
		ASSOC=villagehomesiv
	elif [[ "$1" =~ .*"Villas".* ]] || [[ "$1" =~ .*"Villas[[:space:]]At[[:space:]]Southern[[:space:]]Ridge".* ]]; then
		ASSOC=villasatsouthernridge
	else
		>&2 echo "File $1 did not match; is this a new association or is the filename pattern wrong?"
	fi
}

OIFS="$IFS"
IFS=$'\n'
for i in $(find $SOURCE -type f); do
	ASSOC=
	YEAR=
	TOPIC=
	checkAssoc "$i"
	checkYear "$i"
	checkTopic "$i"
	if [[ -z $ASSOC ]] || [[ -z $YEAR ]] || [[ -z $TOPIC ]]; then
		>&2 echo "Variable is unset: |$ASSOC|$YEAR|$TOPIC|"
		>&2 echo "File $i did not allow us to match something known."	# http://www.tldp.org/LDP/abs/html/io-redirection.html
	else
		DEST=${TARGET}/${ASSOC}/${TOPIC}/${YEAR}/ 
		mv "$i" $DEST
		>&2 echo "File $i moved to $DEST" 
	fi
done
IFS="$OIFS"
exit 0
