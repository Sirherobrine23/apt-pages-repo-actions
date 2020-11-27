#!/bin/bash
if [ $INPUT_DEBUG == 'true' ];then
 echo 'Find'
 ls $PWD/package
fi
# Pacotes
if [ -d package ];then
 echo "linkando os pacotes"
 cp -rfv $PWD/package /aptly/package
else
   echo "not found folder"
   exit 130
fi
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
echo "Sua id da chave publica e privada é: $INPUT_KEY_ID"
echo "----------------------------------------------------"
# Confirações
if [ -e $INPUT_CONF_FILE ];then
    cp -f $INPUT_CONF_FILE /aptly/aptly.conf
else
    wget https://github.com/Sirherobrine23/APT_bysh23/raw/master/aptly.conf -O /aptly/aptly.conf
fi
rm -rf ~/.aptly.conf
ln -s /aptly/aptly.conf ~/.aptly.conf

# ------------------------------------------------------
    if [ -d $gpg_folder ];then
     echo "Pasta do gpg: $gpg_folder"
     mkdir -p "$gpg_folder"
     chown -R $(whoami) "$gpg_folder/"
     chown -R $(whoami) "$gpg_folder"
     chmod 600 "$gpg_folder/*"
     chmod 700 "$gpg_folder"
     echo "---------------------------------------"
    fi
    echo "default-key $INPUT_KEY_ID" >> $gpg_folder/gpg.conf
    echo use-agent >> $gpg_folder/gpg.conf
    echo "pinentry-mode loopback" >> $gpg_folder/gpg.conf
    echo "allow-loopback-pinentry" >> $gpg_folder/gpg-agent.conf
    echo "UPDATESTARTUPTTY" | gpg-connect-agent
    echo "RELOADAGENT" | gpg-connect-agent
    gpg -v --passphrase "$INPUT_PASS" --no-tty --batch --yes --import <(cat "keys/$INPUT_PRIV_KEY")
    gpg -v --import <(cat "keys/$INPUT_PUB_KEY")
    echo "Gpg inport key sucess"
    statusONE='1'
# ------------------------------------------------------
if [ $statusONE == '1' ];then
ls /aptly/package
 cd /aptly/
     for as in $(ls /aptly/package)
     do
         aptly repo create -distribution=$INPUT_DIST -component=$as $as
         aptly repo add  $as /aptly/package/$as/*.deb
         if [ -z $cop ] ;then
             cop="$as"
         else
             cop="$cop $as"
         fi
         if [ -z $cop2 ] ;then
             cop2="$as"
         else
             cop2="$cop2,$as"
         fi
     done
     aptly publish repo -passphrase="$INPUT_PASS" -batch -label="$INPUT_DIST" -component=$cop2 $cop
     statusTWO='1'
else
 echo "Sua chave não foi Importada ou teve algun erro, por favor verique as confiurações e o logs ou se não deixe uma issue no https://github.com/Sirherobrine23/APT-Pages-Docke/issues"
 exit 127
fi
# ------------------------------------------------------
if [ $statusTWO == '1' ];then
  if [ -d /aptly/public/ ];then
   cd /aptly/public/
  else
   echo 'Erro'
   exit 2
  fi
    # Key
    gpg --armor --output /aptly/public/Release.gpg --export $INPUT_KEY_ID

    POOL="$(ls pool/)"
    KEYGPG="$(cat Release.gpg)"
    echo "
    #!/bin/bash
    echo '$KEYGPG' | apt-key add -
    echo "deb $INPUT_URL_REPO $INPUT_DIST $POOL" > /etc/apt/sources.list.d/$INPUT_DIST.list
    apt update
    " > add-repo.sh
    sudo apindex .
    # Criando algumas pastas e publicando
    sudo mkdir -p /public
    sudo chown $USER:$GROUP /public
    sudo chmod 777 /public
    mkdir -p $WORKDIR_SH23/public
    cp -rfv /aptly/public/* /public
    cp -rfv /aptly/public/* $WORKDIR_SH23/public
else
 echo "Tivemos algun erro no reprepro ou não foi executado normamente, por favor verifique suas confiurações ou deixe uma issue no https://github.com/Sirherobrine23/APT-Pages-Docke/issues"
 exit 127
fi


exit 0