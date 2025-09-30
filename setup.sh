chmod +x ~/DurusAud/script.sh
chmod +x ~/DurusAud/_script.sh

touch ~/rundurusaud.sh 
echo '~/DurusAud/script.sh' > ~/rundurusaud.sh

chmod +x ~/rundurusaud.sh

# The prefix path is based on Termux Storage
BASE="/data/data/com.termux/files/home/$1"
SOURCE="/data/data/com.termux/files/home/storage/shared/$2"

upsertEnv () {
  grep -q "^export $1=" ~/.profile && \
  sed -i "s|^export $1=.*|export $1='$2'|" ~/.profile || \
  
  echo "export $1='$2'" >> ~/.profile
}

upsertEnv "DURUSAUD_BASEPATH" $BASE
upsertEnv "DURUSAUD_SOURCE" $SOURCE

source ~/.profile