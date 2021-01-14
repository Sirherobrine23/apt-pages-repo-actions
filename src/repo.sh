#!/bin/bash
echo "Por qualquer problema nos informe pela issue no seguinte link: https://github.com/Sirherobrine23/APT-Pages-Docke/issues"
echo "E Também uma copia do Log"

WORKDIR_SH23="$(pwd)"
gpg_folder=$(gpg-connect-agent --help | grep 'Home:' | sed 's|Home: ||g')

echo "--------------------------------------------------------"
echo "O Diretorio está: $WORKDIR_SH23"
echo "A distro selecionada: $INPUT_DIST"
echo "Opção atual do debug é: $INPUT_DEBUG"
echo "Seu arquivo de chave publica é: $INPUT_PUB_KEY"
echo "Seu arquivo de chave privada é: $INPUT_PRIV_KEY"
echo "The $INPUT_KEY_ID entry is unnecessary"
echo "----------------------------------------------------"
# Confirações
echo "{
  \"rootDir\": \"$PWD/aptly\",
  \"downloadConcurrency\": 4,
  \"downloadSpeedLimit\": 0,
  \"downloadRetries\": 0,
  \"databaseOpenAttempts\": -1,
  \"architectures\": [],
  \"dependencyFollowSuggests\": false,
  \"dependencyFollowRecommends\": false,
  \"dependencyFollowAllVariants\": false,
  \"dependencyFollowSource\": false,
  \"dependencyVerboseResolve\": false,
  \"gpgDisableSign\": false,
  \"gpgDisableVerify\": false,
  \"gpgProvider\": \"gpg\",
  \"downloadSourcePackages\": false,
  \"skipLegacyPool\": false,
  \"ppaDistributorID\": \"ubuntu\",
  \"ppaCodename\": \"focal\",
  \"skipContentsPublishing\": false,
  \"FileSystemPublishEndpoints\": {},
  \"S3PublishEndpoints\": {},
  \"SwiftPublishEndpoints\": {}
}" > ~/.aptly.conf

# ------------------------------------------------------
# Import key
echo "---------------------------------------"
echo "Folder for gpg: $gpg_folder"
mkdir -p "$gpg_folder"
chown -R $(whoami) "$gpg_folder/"
chmod 600 "$gpg_folder/*"
chmod 700 "$gpg_folder"
echo "---------------------------------------"
echo "Adding the keys"
gpg -v --passphrase "$INPUT_PASS" --no-tty --batch --yes --import <(cat "keys/$INPUT_PRIV_KEY")
gpg -v --import <(cat "keys/$INPUT_PUB_KEY")
KEY_ID="$(gpg --list-keys|grep -v 'pub'|grep -v 'uid'|grep -v 'sub'|grep -v '-'|tr '\n' ' ' |sed 's| ||g')"
echo "default-key $KEY_ID" >> $gpg_folder/gpg.conf
echo use-agent >> $gpg_folder/gpg.conf
echo "pinentry-mode loopback" >> $gpg_folder/gpg.conf
echo "allow-loopback-pinentry" >> $gpg_folder/gpg-agent.conf
echo "UPDATESTARTUPTTY" | gpg-connect-agent
echo "RELOADAGENT" | gpg-connect-agent
echo "Gpg inport key sucess"
# ------------------------------------------------------
# Crete repo dists
cd package
echo "Adding files to the repository pool"
for as in *
do
    aptly repo create -distribution=$INPUT_DIST -component=${as} ${as}
    aptly repo add ${as} ${as}/*.deb
    if [ -z $cop ];then
        cop="$as"
    else
        cop="$cop $as"
    fi
    if [ -z $cop2 ];then
        cop2="$as"
    else
        cop2="$cop2,$as"
    fi
done
echo "generating the repository"
if ! aptly publish repo -passphrase="$INPUT_PASS" -batch -label="$INPUT_DIST" -component=$cop2 $cop;then
    aptly_erro=$?
    echo "Aptly exit with code ${aptly_erro}"
    exit ${aptly_erro}
fi
echo "Sucess"
cd ../
# ------------------------------------------------------
MORE_SCRIPT="$(cat ${INPUT_SCRIPT_ADD})"
if [ -d aptly/public ];then
    cd aptly/public
else
    echo 'Error 2 repository was not successfully created'
    exit 2
fi
# Key
gpg --armor --output Release.gpg --export $KEY_ID
# 
if echo $INPUT_URL_REPO|grep -q 'http';then
    repo_url="$INPUT_URL_REPO"
else
    repo_url="https://$GITHUB_REPOSITORY_OWNER.github.io/$(echo $GITHUB_REPOSITORY| sed "s|$GITHUB_REPOSITORY_OWNER/||g")"
    echo "Repository Link: https://$GITHUB_REPOSITORY_OWNER.github.io/$(echo $GITHUB_REPOSITORY|sed 's|/|/ |g'|awk '{print $2}')"
fi
#
POOL="$(ls pool/)"
KEYGPG="$(cat Release.gpg)"
#
if [ $INPUT_STYLE == 'debian' ];then
#
echo -e "set -x
echo '$KEYGPG'|apt-key add -
echo \"deb $repo_url $INPUT_DIST $POOL\" > /etc/apt/sources.list.d/$INPUT_DIST.list
${MORE_SCRIPT}
apt update" > add-repo.sh
#
else
#
echo -e "set -x
if command -v /data/data/com.termux/files/usr/bin/bash &> \$TMPDIR/null;then
#
echo \'$KEYGPG\'|apt-key add -
echo \"deb $repo_url $INPUT_DIST $POOL\" > $PREFIX/etc/apt/sources.list.d/$INPUT_DIST.list
${MORE_SCRIPT}
apt update
#
else
    echo 'You are not using termux'
    exit 1
fi" > add-repo.sh
#
fi
apindex .
if ! echo "$repo_url"|grep -q '.github.io/';then
    echo "$repo_url" > CNAME
fi
exit 0