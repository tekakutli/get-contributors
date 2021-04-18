#!/usr/bin/env bash


REPOSITORY=$(echo $1 | cut -f-5 -d"/")
#for the message if the fetch fails due to API limit
COMANDO='bash get-forks.sh '$REPOSITORY

github-scrap(){
#API linked contributors
cat rawfetch* | grep "\"login\"" >> aplogin0
cat aplogin0 | cut -c 15- > aplogin1
sed -i 's/\",//' aplogin1
awk '$0="https://github.com/"$0' aplogin1 > aplogin2

#API anonymous contributors
cat rawfetch* | grep "noreply.github" >> apnoreply0
cat apnoreply0 | cut -c 15- > apnoreply1
sed -i 's/@users.noreply.github.com\",//' apnoreply1
sed -i 's/*+//' apnoreply1
sed -i 's/^[^+]*+//' apnoreply1
awk '$0="https://github.com/"$0' apnoreply1 > apnoreply2

#Output results
cat aplogin2 apnoreply2 > apoutput
sort -u ../$APIFOLDER/apoutput > ../${NAME}
}

github-fetch(){

REPO=../$1
mkdir -p $REPO
cd $REPO
URL=$2
#global counter
FOLDER=../get-contributors/

fetch(){
    URLAPI='https://api.github.com/repos/'$URL
    URLAPI=$URLAPI'/contributors?per_page=90&anon=1&page='$i
    curl --silent -H "Accept: application/vnd.github.v3+json" $URLAPI > $FILE

    ${FOLDER}github-valid.sh $FILE "$COMANDO" || exit 1

    #if the retrieved file is empty, no further fetch in needed
    if cmp -s $FILE ${FOLDER}empty;then
        github-scrap
        exit
    fi
}

for i in {1..100}
do
    FILE='rawfetch-page-'$i
    #when re runned it skips the fetch of pages already downloaded
    if [ -f $FILE ]; then
        #when re runned it re fetches each page if previously it had API limit error
       if grep -q 'API rate limit exceeded' "$FILE"; then
           fetch
       else
           continue
       fi
    else
        fetch
    fi
done
github-scrap

}

URL=$(echo $1 | cut -f4,5 -d"/")
NAME=contributors-$(echo $URL | cut -f2 -d"/")
APIFOLDER=api-$NAME
github-fetch $APIFOLDER $URL
