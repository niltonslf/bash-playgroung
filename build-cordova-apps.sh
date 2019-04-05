
#!/bin/bash
projectFolder='./'
appname='vetorlog'


# Processo de build para projetos baseados em quasar
function quasarBuild(){
    projectFolder='src-cordova'
    cd "$projectFolder" && cordova build android --release
    cd ../ # Voltar para pasta raiz do projeto
    copyUsignedApk
    verifyIfExistsKey
    signApk
    zipApp

    showMessage "BUILD FINALIZADO!! SEJA FELIZ :)"
}

# Processo de build para projetos baseados em cordova puro
function cordovaBuild(){
  echo "Not implemented yet"
}

# Função para exibir mensagens com um certo destaque
function showMessage(){
    message=$1
    echo "########################"
    echo $message
    echo "########################\n"
}

# Copiar apk não assinado para a pasta base do projeto
function copyUsignedApk(){
    showMessage "COPIANDO APK PARA RAIZ DO PROJETO"
    # Deletar arquivo se existir
    verifyAndDropIfExists "./app-release-unsigned.apk"
    # COPIAR ARQUIVO
    cp $projectFolder/platforms/android/app/build/outputs/apk/release/app-release-unsigned.apk ./app-release-unsigned.apk
    # eixibir mensagem de conclusão
    showMessage "APK COPIADO"
}

##  Verificar se existe a chave. Se não tiver, gerar uma
function verifyIfExistsKey(){ 
    showMessage "VERIFICANDO CHAVE DO APK"

    file="$appname.keystore"
    #VERIFICAR SE EXISTE
    if [ -f "$file" ]
    then 
    showMessage "CHAVE JÁ EXISTE"
    else
    showMessage "GERANDO CHAVE DO APK"
    # GERAR CHAVE   
    keytool -genkey -v -keystore $appname.keystore -alias app-release-unsigned -keyalg RSA -keysize 2048 -validity 10000
    fi    
}

# Assinar apk com a chave que foi gerada
function signApk(){
    showMessage "ASSINANDO APK"

    jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $appname.keystore app-release-unsigned.apk app-release-unsigned
}

# Otimizar apk
function zipApp(){
    showMessage "OTIMIZANDO APK"
    # Deletar arquivo se existir
    verifyAndDropIfExists "./$appname.apk"
    # EXECUTAR COMANDO
    ~/Library/Android/sdk/build-tools/28.0.3/zipalign -v 4 app-release-unsigned.apk $appname.apk
}

function verifyAndDropIfExists(){
    file=$1
    if [ -f "$file" ]
    then
        rm "$file"
    fi
}


##
## BEGIN OF PROGRAM
##

showMessage 'GENERATING APP BUILD'

# Se for um projeto baseado em quasar haverá um diretório src-cordova
# verificar se esse diretório existe
if [ -d "src-cordova/" ]
then
 showMessage "QUASAR PROJECT DETECTED"
 quasarBuild --verbose
else
 showMessage "CORDOVA PROJECT DETECTED"
fi
