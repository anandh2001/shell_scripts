#!/bin/bash


#create binary file
#/usr/bin/shc -vrf project-setup.sh -o project-setup

export RED="\033[31m"
export NC="\033[0m"
export WHITE="\033[0m"
export BLUE="\033[34m"



#git clone all the required repos
git_clone_pipeline(){

while true; do 

read -r -p "Please enter your workspace directory :  " workspace_dir

if [ ! -d "$workspace_dir" ]; then 
	echo "${RED}  $workspace_dir does not exists. ${WHITE}"
	break
else
	echo "Directory present"  
fi



echo " Git clone For
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
echo "${BLUE}Cloning handyman ${WHITE}"
git clone git@github.com:zucisystems-dev/handyman.git
sleep 1
cd $BASE_DIR/handyman/
git reset --hard HEAD
git pull --rebase
git checkout donut_ut/dev #branch name can be changed
#cp -f $DIR/config.properties $BASE_DIR/handyman/src/main/resources/config.properties
#. ~/.profile_maven

mvn clean antlr4:antlr4 test -Dtest=ActionGenerationTest#generate compile install -DskipTests
echo "${BLUE}Handyman build has been completed handyman-raven-vm-2.0.0.jar"
echo "${BLUE}Cloning handyman finished "

##################### GIT CLONE HANDYMAN END ######################

##################### GIT CLONE APP ###############################
cd $BASE_DIR
echo "${BLUE}Cloning intics-app ${WHITE}"
git clone git@github.com:dinesh-jraman/intics-agadia.git
sleep 1
cd $BASE_DIR/intics-agadia/agadia/
git reset --hard HEAD
git pull --rebase
git checkout enhancement/copro_start_export #branch name can be changed
#cp -f $DIR/config.properties $BASE_DIR/intics-agadia/agadia/src/main/resources/config.properties
cp -f $BASE_DIR/handyman/target/handyman-raven-vm-2.0.0.jar $BASE_DIR/intics-agadia/agadia/lib/

. ~/.profile_maven
mvn install:install-file -Dfile=lib/handyman-raven-vm-2.0.0.jar -DgroupId=in.handyman -DartifactId=raven -Dversion=2.0.0 -Dpackaging=jar -DgeneratePom=true -Dspring.config.location="src/main/resources/config.properties" -DskipTests


. ~/.profile_maven
mvn clean package -DskipTests

echo "${BLUE}JAVA Application Build has been completed${WHITE}"
echo "${BLUE}Cloning intics-app finished ${WHITE}"
##################### GIT CLONE APP END ##############################


######################## GIT CLONE COPRO #############################


echo "${BLUE}Cloning copro ${WHITE}"
cd $BASE_DIR
git clone git@github.com:zucisystems-dev/copro.git

sleep 1
cd $BASE_DIR/copro/

git reset --hard HEAD
git pull --rebase

git checkout master-agadia-v4 #branch name can be changed

echo "${BLUE}Cloning copro finished ${WHITE}"

######################## GIT CLONE COPRO END #############################


######################## GIT CLONE GATEKEEPER ##########################

echo "${BLUE}Cloning gatekeeper ${WHITE}"
cd $BASE_DIR
git clone git@github.com:zucisystems-dev/agadia-gatekeeper.git
sleep 1
cd $BASE_DIR/agadia-gatekeeper/
git reset --hard HEAD
git pull --rebase
git checkout master #branch name can be changed
#cp -f $DIR/config.properties $BASE_DIR/handyman/src/main/resources/config.properties
mvn clean package -DskipTests

echo "${BLUE}Cloning gatekeeper finished ${WHITE}"

######################## GIT CLONE GATEKEEPER END #######################


break
done
}



# 2). setting up copro environment
copro_env(){
	read -r -p "Please enter your copro project directory :  " copro_env_dir

		if [ ! -d "$copro_env_dir" ]; then 
			echo "${RED}  $copro_env_dir does not exists. ${WHITE}"
			break
		else
			echo "Directory present"  
		fi


	cd "$copro_env_dir"
	pip install poetry
	#rm -rf poetry.lock
	poetry install

}



# 3). setting up postgresql database
setup_postgres(){
	if command -v psql &> /dev/null; then
    	echo "${BLUE}PostgreSQL is already installed.${WHITE}"
    	psql --version
    else
    	echo "${BLUE}PostgreSQL is not installed.${WHITE}"
		sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
		wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
		sudo apt-get update
		sudo apt-get -y install postgresql
		sudo -i -u postgres
		psql -c "\password postgres"
		exit
	#sudo apt-get purge postgresql postgresql-contrib
	#sudo apt-get autoremove
	#sudo apt-get update
    #sudo apt-get install postgresql postgresql-contrib
fi

} 



# 4). Load the dump into the database 
Database_Configuration_load(){
	while true; do
		read -r -p "Please enter your sql dump absolute file path :  " sql_file_path
		if [ ! -f "$sql_file_path" ]; then 
			echo "${RED}  $sql_file_path does not exists. ${WHITE}"
			break
		else
			read -r -p "Please enter new database name : " db_name
			psql -U postgres -h localhost -p 5432 -c "create database $db_name;"
			psql -U postgres -h localhost -p 5432 -d $db_name < $sql_file_path
			break
		fi

	done

}


# 5). git clone UI
git_clone_UI(){	

while true; do 

		read -r -p "Please enter your workspace directory :  " workspace_dir

		if [ ! -d "$workspace_dir" ]; then 
			echo "${RED}  $workspace_dir does not exists. ${WHITE}"
			break
		else
			echo "Directory present"  
		fi



		echo " Git clone For
			1. React UI
			2. Java backend"

		echo "The current directory is: $UI_BASE_DIR"
		export UI_BASE_DIR=$workspace_dir/Intics-ui/
		export TARGET_DIR=$workspace_dir/build/jar


		if [ ! -d "$BASE_DIR" ] || [ ! -d "$TARGET_DIR" ] || [ ! -d "$UI_BASE_DIR" ]; then
			mkdir -p $TARGET_DIR
			mkdir -p $UI_BASE_DIR
			echo "Creating directory in $workspace_dir "
		else
			echo "${RED}Directory already exists $workspace_dir ${WHITE}"
		fi


		######################## GIT CLONE INTICS UI ############################

		echo "${BLUE}Cloning intics UI ${WHITE}"
		cd $UI_BASE_DIR
		git clone git@github.com:zucisystems-dev/vulcan.git
		sleep 1
		cd $UI_BASE_DIR/vulcan/
		git reset --hard HEAD
		git pull --rebase
		git checkout dev #branch name can be changed
		#cp -f $DIR/config.properties $BASE_DIR/handyman/src/main/resources/config.properties
		# mvn clean package -DskipTests
			
		echo "${BLUE}Cloning intics UI finished ${WHITE}"


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


# 6). copro start all the servers in byobu
copro_start_server(){


	sudo apt-get install byobu;
	python --version
#byobu kill-session -t "COPRO_LOGS"
if byobu list-sessions | grep -q "COPRO_LOGS"; then
  echo "Copro session exists"
else
  byobu new-session -d -s COPRO_LOGS
  echo "New COPRO_LOGS session created"

fi

        read -r -p "Please enter your workspace directory :  " workspace_dir

		if [ ! -d "$workspace_dir/pipeline/copro/" ]; then 
			echo "${RED}  $workspace_dir/pipeline/copro/ does not exists. ${WHITE}"
			break
		else
			echo "Directory present : $workspace_dir/pipeline/copro/"  
		fi

tabs=(PI AR TE ZSC PM PC QR VALUATION NER MERGER COS IMPIRA UTMODEL)
byobu rename-window -t COPRO_LOGS:0 "PI"

for i in {1..15}; do
  tab="${tabs[i]}"

  byobu new-window -t COPRO_LOGS:$i -n "$tab"
  echo "new tab created $i"

done


containers=(pr1.copro.paper.itemizer pr1.copro.auto.rotation pr1.copro.data.extraction pr1.copro.zsc pr1.copro.pm pr1.copro.paper.classification pr1.copro.qr pr1.copro.valuation pr1.copro.ner pr1.copro.merger pr1.copro.cossimilarity pr1.copro.impira pr1.copro.utmodel)
ports=(10280 10281 10282 10283 10284 10285 10286 10289 10290 10291 10292 10293 10294)


for i in "${!containers[@]}"; do
  container="${containers[i]}"
  port="${ports[i]}"
  tab="${tabs[i]}"
  byobu send-keys -t COPRO_LOGS:$i "cd $workspace_dir/pipeline/copro/" Enter
  #byobu send-keys -t COPRO_LOGS:$i "poetry shell" Enter
  byobu send-keys -t COPRO_LOGS:$i "poetry run uvicorn app.copro_admin_api:app --host 127.0.0.1 --port $port" Enter
  echo "Copro logs started for $container with port and window $tab"
done

}


vulcan_start_server(){
read -r -p "Please enter your workspace directory :  " workspace_dir

	if [ ! -d "$workspace_dir" ]; then 
		echo "${RED}  $workspace_dir does not exists. ${WHITE}"
		break
	else
		echo "Directory present"  
		cd $workspace_dir/Intics-ui/vulcan/

		npm i
		npm run build
		npm start &

	fi
	
}


copro_server_stop(){
	byobu kill-session -t "COPRO_LOGS"
}

vulcan_stop_server(){

		#kill $(lsof -i :3000)

}



# 7) UI setup 
vulcan_npm_setup(){


	npm_version=$(npm -v 2>/dev/null)

	if [ $? -eq 0 ]; then
		echo "npm is already installed (version $npm_version)."
		vulcan_start_server

	else
		echo "npm is not installed. Installing npm..."

		# Install npm (you can adjust the installation command based on your system)
		# This example is for Linux (Debian/Ubuntu).
		sudo apt-get update
		sudo apt-get install -y npm

	# Verify the installation
	npm_version=$(npm -v)
	echo "npm has been installed (version $npm_version)."
	vulcan_start_server
	fi
	
}

optionsList(){
	echo '+────────────────────────────────────────────────────────────────────────────────────────────────+
|                                                                                                |
|    1) Git clone all the repository(pipeline)  |  2) Create python environment                  |
|    3) Setup postgres database                 |  4) Database SQL dump load                     |
|    5) Git clone all the repository(Intics-ui) |  6) copro server start                         |
|    7) copro server stop                       |  8)  Intics-ui npm install                     |
|    9) Intics-ui server start                  |  10) Intics-ui server stop                     |
|    q) quit                                                                                     |
|    l) clear                                                                                    |
|                                                                                                |
+────────────────────────────────────────────────────────────────────────────────────────────────+'
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
			1) git_clone_pipeline ;;
			2) copro_env;;
			3) setup_postgres;;
			4) Database_Configuration_load;;
			5) git_clone_UI;;
			6) copro_start_server;;
			7) copro_server_stop;;
			8) vulcan_npm_setup;;
			9) vulcan_start_server;;
			10) vulcan_stop_server;;
			0) optionsList ;;
			*) echo "invalid option"
optionsList

 esac

done

