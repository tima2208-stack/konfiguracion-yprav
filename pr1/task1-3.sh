#Zadanie #1

cut -d: -f1 /etc/passwd | sort
_accessoryupdater
_amavisd
_analyticsd
_appinstalld
_appleevents
_applepay
_appowner
_appserver
_appstore
_ard
_assetcache
_astris
_atsserver
_audiomxd
_avbdeviced
_avphidbridge
_backgroundassets
_biome
_calendar
_captiveagent
_ces
_clamav
_cmiodalassistants
_coreaudiod
_coremediaiod
_coreml
_ctkd
_cvmsroot
_cvs
_cyrus
_darwindaemon
_datadetectors
_demod
_devdocs
_devicemgr
_diskimagesiod
_displaypolicyd
_distnote
_dovecot
_dovenull
_dpaudio
_driverkit
_eppc
_findmydevice
_fpsd
_ftp
_gamecontrollerd
_geod
_hidd
_iconservices
_installassistant
_installcoordinationd
_installer
_jabber
_kadmin_admin
_kadmin_changepw
_knowledgegraphd
_krb_anonymous
_krb_changepw
_krb_kadmin
_krb_kerberos
_krb_krbtgt
_krbfast
_krbtgt
_launchservicesd
_lda
_locationd
_logd
_lp
_mailman
_mbsetupuser
_mcxalr
_mdnsresponder
_mmaintenanced
_mobileasset
_mobilegestalthelper
_mysql
_nearbyd
_netbios
_netstatistics
_networkd
_neuralengine
_notification_proxy
_nsurlsessiond
_oahd
_ondemand
_postfix
_postgres
_qtss
_reportmemoryexception
_rmd
_sandbox
_screensaver
_scsd
_securityagent
_sntpd
_softwareupdate
_spotlight
_sshd
_svn
_taskgated
_teamsserver
_terminusd
_timed
_timezone
_tokend
_trustd
_trustevaluationagent
_unknown
_update_sharing
_usbmuxd
_uucp
_warmd
_webauthserver
_windowserver
_www
_wwwproxy
_xserverdocs

#Zadanie #2
awk '{print $2, $1}' /etc/protocols | sort -nr | head -n 5
258 divert
240 pfsync
142 rohc
141 wesp
140 shim6

#Zadanie #3

#!/bin/bash

text=$*
length=${#text}

for i in $(seq 1 $((length + 2))); do
    line+="-"
done

echo "+${line}+"
echo "| ${text} |"
echo "+${line}+"
