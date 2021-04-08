ORACLE_HOME=/appl/oracle/RDBMS/product/9.2.0.7                          export ORACLE_HOME


PATH=$PATH:/usr/local/bin:/appl/oracle/RDBMS/product/9.2.0.7/bin         export PATH

ORACLE_SID=HIST                                                           export ORACLE_SID

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib

rm -f /hist/oradata/u11/ARTP/NEW/*.*

cd /hist/oradata/u11/ARTP

! /appl/oracle/RDBMS/product/9.2.0.7/bin/sqlplus /nolog @artp_post_daily.sql

#mv -f INTER* `echo INTER* |awk '{print substr($1,1,13)}'`
#mv -f TTFILE* `echo TTFILE* |awk '{print substr($1,1,14)}'`A
#currfile=`ls /hist/oradata/u11/ARTP/TTFILE* 2>/dev/null | awk -F'/' '{print $6}'`
ls /hist/oradata/u11/ARTP/TTFILE* 2>/dev/null | awk -F'/' '{print $6}' > currfile
ls /hist/oradata/u11/ARTP/INTER* 2>/dev/null | awk -F'/' '{print $6}' >> currfile

fcount=0
count=`cat currfile | wc -l`
while [ $count -ge 1 ]
      do
      fcount=`expr $fcount + 1`
      thefile=`sed -n "$fcount","$fcount"p currfile`
      if [ -f /hist/oradata/u11/ARTP/$thefile ]
      then
	echo "le fichier "$thefile
	vresult=`grep "rows selected" $thefile | wc -l`
	if [ $vresult -eq 1 ]
	then
		sed '/^$/d' $thefile > filetmp1
		sed '/rows selected/d' filetmp1 > filetmp2
		cp $thefile bkpttfile
		mv filetmp2 $thefile
		mv $thefile /hist/oradata/u11/ARTP/NEW
	else
		mv $thefile /hist/oradata/u11/ARTP/bad
	fi
	count=`expr $count - 1`
      fi
done
currfile=`ls /hist/oradata/u11/ARTP/NEW/* 2>/dev/null | awk -F'/' '{print $7}'`
for thefile in $currfile
do
if [ -f /hist/oradata/u11/ARTP/NEW/$thefile ]
then
	echo "**************************************************************"$thefile
	ipadd=192.168.1.43
	usr=bgw
	paswd=thule
	ftpresults=`ftp -nv $ipadd <<HERE
	user $usr $paswd
        cd /var/opt/BGw/Server1/atrpt
	lcd /hist/oradata/u11/ARTP/NEW
	mput $thefile 
	bye
	HERE`
	echo "result=  $ftpresults"
	ftp_ctr=""
	ftp_ctr=`echo $ftpresults | grep "226 Transfer OK"| wc -l`
	if [ $ftp_ctr -eq 1 ]
	then
		cd /hist/oradata/u11/ARTP/NEW
		mv $thefile /hist/oradata/u11/ARTP/OLD
     		echo "`date '+%d %h %y %R'` =====${fname} is transferd"
	fi
fi
done

