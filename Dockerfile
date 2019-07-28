# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

FROM registry:8082/tomcat:1
MAINTAINER shaun      

RUN cd /                 
ADD ./target/jenkinsfile-test.war /apache-tomcat-8.0.32/webapps

CMD ["/apache-tomcat-8.0.32/bin/catalina.sh", "run"]
