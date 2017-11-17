#$1 - what to do
#$2 - build number

case $1 in
 deploy)
 	######backup
  	cd /tmp/
 	scp root@tomcat.local:/opt/apache-tomcat-8.5.23/webapps/hello-world/WEB-INF/bn.txt ./	
    build=$(cat bn.txt)	
    curl -I http://nexus.local:8081/repository/hello-world/hello-world/hello-world/$build/hello-world-$build.war | grep "200 OK" > /dev/null
    if [ $? -eq 1 ]; then
    	scp root@tomcat.local:/opt/apache-tomcat-8.5.23/webapps/hello-world.war ./
        if [ $? ]; then
    	curl -v -u admin:admin123 --upload-file ./hello-world.war http://nexus.local:8081/repository/hello-world/hello-world/hello-world/$build/hello-world-$build.war
        else
        	echo "FAIL!Something wrong while scp!"
        fi
    else
		echo "Build number $build is already in nexus. No need to backup"    
    fi	
    #######deploy
	cd /tmp/
	wget http://nexus.local:8081/repository/hello-world/hello-world/hello-world/$2/hello-world-$2.war
    curl "http://deploy:deploy@tomcat.local:8080/manager/text/undeploy?path=/hello-world"
	curl --upload-file /tmp/hello-world-$2.war "http://deploy:deploy@tomcat.local:8080/manager/text/deploy?path=/hello-world&update=true"
 ;;
 check)
 	curl http://tomcat.local:8080/hello-world/hello | grep "This is $BUILD build" > /dev/null
    if [ $? -eq "1" ]; then
    	echo "The content is wrong. We must restore"
        wget http://nexus.local:8081/repository/hello-world/hello-world/hello-world/$(($2 - 1))/hello-world-$(($2 - 1)).war
    	curl "http://deploy:deploy@tomcat.local:8080/manager/text/undeploy?path=/hello-world"
		curl --upload-file /tmp/hello-world-$2.war "http://deploy:deploy@tomcat.local:8080/manager/text/deploy?path=/hello-world&update=true"
    fi 	
 ;;	
 mrestore)
 	cd /tmp
    build=$(echo $2| cut -d/ -f2)
 	wget http://nexus.local:8081/repository/hello-world/hello-world/hello-world$2
    curl "http://deploy:deploy@tomcat.local:8080/manager/text/undeploy?path=/hello-world" && curl --upload-file /tmp/hello-world-$build.war "http://deploy:deploy@tomcat.local:8080/manager/text/deploy?path=/hello-world&update=true"
 ;;   
 *)
 	echo "deploy|check|mrestore"
 ;;   
esac

