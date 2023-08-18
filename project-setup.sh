#!/bin/bash

#/usr/bin/shc -vrf agadia-deploy_UAT.sh -o agadia-deploy_UAT.sh

export RED="\033[31m"
export NC='\033[0m'
export WHITE="\033[0m"

gitClone(){

while true; do 

read -r -p "Please enter your workspace directory :  " workspace_dir

if [ ! -d "$workspace_dir" ]; then 
	echo "${RED}  $workspace_dir does not exists. ${WHITE}"
	break
else
	echo "Directory present"  
fi



echo " Build For
	1. Copro  ----- python
  		2. HandyMan --- jar
	3. APP-jar  --- jar
	4. Gateway  --- jar"

##### Create profile #######
/bin/cat <<EOM > ~/.profile_maven
M2_HOME='/usr/share/maven'
PATH="$M2_HOME/bin:$PATH"
export PATH
EOM


##### Create ENVIRONMENT #####



echo "The current directory is: $workspace_dir"
export BASE_DIR=$workspace_dir/pipeline/
export UI_BASE_DIR=$workspace_dir/Intics-ui/
export TARGET_DIR=$workspace_dir/build/jar


if [ ! -d "$BASE_DIR" ] || [ ! -d "$TARGET_DIR" ] || [ ! -d "$UI_BASE_DIR" ]; then
	mkdir -p $BASE_DIR
	mkdir -p $TARGET_DIR
	mkdir -p $UI_BASE_DIR
	echo "Creating directory in $workspace_dir "
else
	echo "${RED}Directory already exists $workspace_dir ${WHITE}"
fi


##################### GIT CLONE HANDYMAN ########################

cd $BASE_DIR
echo "Cloning handyman "
git clone git@github.com:zucisystems-dev/handyman.git
sleep 1
cd $BASE_DIR/handyman/
git reset --hard HEAD
git pull --rebase
git checkout donut_ut/dev #branch name can be changed
#cp -f $DIR/config.properties $BASE_DIR/handyman/src/main/resources/config.properties
#. ~/.profile_maven

mvn clean antlr4:antlr4 test -Dtest=ActionGenerationTest#generate compile install -DskipTests
echo "Handyman build has been completed handyman-raven-vm-2.0.0.jar"
echo "Cloning handyman finished "

##################### GIT CLONE HANDYMAN END ######################

##################### GIT CLONE APP ###############################
cd $BASE_DIR
echo "Cloning intics-app "
git clone git@github.com:dinesh-jraman/intics-agadia.git
sleep 1
cd $BASE_DIR/intics-agadia/agadia/
git reset --hard HEAD
git pull --rebase
git checkout enhancement/copro_start_export #branch name can be changed
#cp -f $DIR/config.properties $BASE_DIR/intics-agadia/agadia/src/main/resources/config.properties
#cp -f $BASE_DIR/handyman/target/handyman-raven-vm-2.0.0.jar $BASE_DIR/intics-agadia/agadia/lib/

. ~/.profile_maven
mvn install:install-file -Dfile=lib/handyman-raven-vm-2.0.0.jar -DgroupId=in.handyman -DartifactId=raven -Dversion=2.0.0 -Dpackaging=jar -DgeneratePom=true -Dspring.config.location="src/main/resources/config.properties" -DskipTests


. ~/.profile_maven
mvn clean package -DskipTests

echo "JAVA Application Build has been completed"
echo "Cloning intics-app finished "
##################### GIT CLONE APP END ##############################


######################## GIT CLONE COPRO #############################


echo "Cloning copro "
cd $BASE_DIR
git clone git@github.com:zucisystems-dev/copro.git

sleep 1
cd $BASE_DIR/copro/

git reset --hard HEAD
git pull --rebase

git checkout master-agadia #branch name can be changed

echo "Cloning copro finished "

######################## GIT CLONE COPRO END #############################


######################## GIT CLONE GATEKEEPER ##########################

echo "Cloning gatekeeper "
cd $BASE_DIR
git clone git@github.com:zucisystems-dev/agadia-gatekeeper.git
sleep 1
cd $BASE_DIR/agadia-gatekeeper/
git reset --hard HEAD
git pull --rebase
git checkout master #branch name can be changed
#cp -f $DIR/config.properties $BASE_DIR/handyman/src/main/resources/config.properties
mvn clean package -DskipTests

echo "Cloning gatekeeper finished "

######################## GIT CLONE GATEKEEPER END #######################



######################## GIT CLONE INTICS UI ############################

# echo "Cloning intics UI "
# cd $UI_BASE_DIR
# git clone git@github.com:zucisystems-dev/vulcan.git
# sleep 1
# cd $UI_BASE_DIR/vulcan/
# git reset --hard HEAD
# git pull --rebase
# git checkout dev #branch name can be changed
# #cp -f $DIR/config.properties $BASE_DIR/handyman/src/main/resources/config.properties
# # mvn clean package -DskipTests
	
# echo "Cloning intics UI finished "


######################## GIT CLONE INTICS UI END############################

######################## GIT CLONE INTICS UI ############################

# echo "Cloning intics UI "
# cd $UI_BASE_DIR
# git clone git@github.com:zucisystems-dev/vulcan.git
# sleep 1
# cd $UI_BASE_DIR/vulcan/
# git reset --hard HEAD
# git pull --rebase
# git checkout master #branch name can be changed
# #cp -f $DIR/config.properties $BASE_DIR/handyman/src/main/resources/config.properties
# # mvn clean package -DskipTests

# echo "Cloning intics UI finished "


######################## GIT CLONE INTICS UI END############################
break
done

}

optionsList(){
	echo '+───────────────────────────────────────────────────────────+
|                                                           |
|    1) Git clone all the repository                        |
|    q) quit                                                |
|    l) clear                                               |
|                                                     ANDREW|
+───────────────────────────────────────────────────────────+'
}



NC='\033[0m'


optionsList 

while true; do



	read -r -p "Please enter your option :  " n
	case $n in
			Q) break ;;
			q) break ;;
			L) clear ;;
			l) clear ;;
			1) gitClone ;;
			0) optionsList ;; 


	

 esac

done

