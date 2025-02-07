#!/bin/bash
BRANCHNAME=$1
NCORES=1
YEARP=$2 #2016->2018
TYPEP=$3 #MC or DATA
SAMPLEFILENAME=$4 # ULX.txt
OutputLabel=$5
NFSTART=${6:-0} #FromFile
NFEND=${7:--1} #ToFile
SPACING_FACTOR=${8:-1.15}
LIMIT_EDGE=${9:-1350.0}
FIRSTBIN_LEFTEDGE=${10:-60.0}
FIRSTBIN_RIGHTEDGE=${11:-70.0}
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=el9_amd64_gcc12
scram project CMSSW CMSSW_13_3_0_pre4
cd CMSSW_13_3_0_pre4/src
cmsenv
eval `scram runtime -sh`
echo  "CMSSW Dir: "$CMSSW_BASE
git clone --branch $BRANCHNAME https://github.com/castaned/WprimeSearch Wprime_$YEARP
WprimeDir=$PWD/Wprime_$YEARP/
echo "Analysis Dir: "$WprimeDir
#sed -i 's/cmsxrootd.fnal.gov/xrootd-cms.infn.it/' $WprimeDir/proof/Selector.C
#sed -i 's/cmsxrootd.fnal.gov/xrootd.unl.edu/' $WprimeDir/proof/Selector.C
sed -i 's/cmsxrootd.fnal.gov/cms-xrd-global.cern.ch/' $WprimeDir/proof/Selector.C
cd $WprimeDir/proof
wget -c https://raw.githubusercontent.com/castaned/files/refs/heads/main/x509up_u47450
export X509_USER_PROXY=$PWD/x509up_u47450
voms-proxy-info -all
voms-proxy-info -all -file $X509_USER_PROXY

cd $WprimeDir/proof/

BINOPTIONS="#define SPACING_FACTOR ${SPACING_FACTOR}\n#define FIRSTBIN_LEFTEDGE ${FIRSTBIN_LEFTEDGE}\n#define FIRSTBIN_RIGHTEDGE ${FIRSTBIN_RIGHTEDGE}\n#define LIMIT_EDGE ${LIMIT_EDGE}\n"
echo $BINOPTIONS

if [ "$TYPEP" =  "MC" ]; then
    export SAMPLEFILE=$WprimeDir/proof/files/mc/$YEARP/UL/$SAMPLEFILENAME
    export ENTRYLISTFILE=""
    echo -e "#define Y"$YEARP"\n#define ULSAMPLE\n${BINOPTIONS}" > IsData.h # Make sure CMSDATA is undefined
elif [ "$TYPEP" = "DATA" ]; then
    export SAMPLEFILE=$WprimeDir/proof/files/data/$YEARP/UL/$SAMPLEFILENAME
    export ENTRYLISTFILE="root://cmseos.fnal.gov//store/user/avargash/WprimeSearch/proof/EntryListMaker/EntryLists_Unique.root"
    echo -e "#define Y"$YEARP"\n#define CMSDATA\n#define ULSAMPLE\n${BINOPTIONS}" > IsData.h
fi
ROOTCommand="\""$OutputLabel"\",\""$SAMPLEFILE"\","$NCORES",\""$ENTRYLISTFILE"\",$NFSTART,$NFEND";
root -l -b -q "Selector.C("$ROOTCommand")";


cd $WprimeDir/proof/
for i in `ls WprimeHistos_*.root`;
do
#    xrdcp -vf $i root://cmseos.fnal.gov//store/user/avargash/WprimeSearchCondorOutput/$i
done
