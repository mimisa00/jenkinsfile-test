pipeline {
    agent { 
        label 'master'
    }
    tools {
        maven 'mvn-werp' // SET BY Global Tool Configuration
        jdk 'jdk-werp'   // SET BY Global Tool Configuration
    }
    environment {
        approvalMap = ''
    }
    stages {
        stage("Build") {
            agent { 
                label 'docker-env'
            }
            steps {
                defBuildImage()
            }
        }
        stage("SIT"){
            when {
                branch 'SIT';
            }
            agent { 
                label 'sit'
            }
            steps {
               defDeploySIT()
            }
        }
        stage("TRIAL"){
            when {
               branch 'TRIAL'
            }
            agent { 
                label 'sit'
            }
            steps {
                //由於各區trial不同，故需拋入字串參數以辨識佈署區域
                defDeployTRIAL("COMMON-TRIAL")
            }
        }
        stage("QAT"){
            when {
               branch 'QAT'
            }
            steps {
                defDeployQAT()
            }
        }
        stage("UAT"){
            when {
               branch 'UAT'
            }
            steps {
                defDeployUAT()
            }
        }
        stage("RL"){
            when {
               branch 'RL' 
            }
            steps {
                //RL & PRL皆在此區進行部署
                defConfirmDeployRL()
            }
        }
        stage("PRL"){
            when {
               branch 'PRL'
            }
            steps {
                defConfirmDeployPRL()
            }
        }
    }
}

def defBuildImage() {
    def artifactId = getPomArtifactId()
    def pomVersion = getPomVer()
    def loctag = "${BRANCH_NAME}"
    sh "mvn clean install package"
    removeImage("$artifactId","$loctag")
    withDockerRegistry(credentialsId: 'c4591403-3ffb-4e1b-8231-cfb132fdb14f', url: 'http://registry:8082') {
        sh "docker build -t registry:8082/$artifactId:$loctag ."
        sh "docker push registry:8082/$artifactId:$loctag"
        //sh "docker build -t registry:8082/$artifactId:$pomVersion ."
        //sh "docker push registry:8082/$artifactId:$pomVersion"
        //sh "docker tag registry:8082/$artifactId:$pomVersion registry:8082/$artifactId:latest"
        //sh "docker push registry:8082/$artifactId:latest"
    }
}

def getPomArtifactId() {
    // function by pipeline-utility-steps (jenkins plugin)
    return readMavenPom().getArtifactId()
}

def getPomVer() {
    // function by pipeline-utility-steps (jenkins plugin)
    return readMavenPom().getVersion();
}

def removeImage(String artifactId,String loctag){
    removeContainer("$artifactId")
    def imageid = sh(script: "docker images registry:8082/$artifactId:$loctag -q", returnStdout: true).trim()
    if (imageid != ''){
        try {
            sh "docker rmi registry:8082/$artifactId:$loctag"
        } catch (err) {
            echo "$err"
        }
    }
}

def removeContainer(String artifactId){
    def containerid = sh(script: "docker ps --quiet --filter name=$artifactId", returnStdout: true).trim()
    if (containerid != ''){
        sh "docker rm -f $artifactId"
    }
}

def defDeploySIT(){
    def artifactId = getPomArtifactId()
    def pomVersion = getPomVer()
    def loctag = "${BRANCH_NAME}"
    removeImage("$artifactId","$loctag")
    
    //sh "docker run -t -d -p 8888:8080 --name $artifactId --restart=always --privileged -v /usr/local/tomcat/conf:/home/docker/$artifactId/conf  -e JAVA_HOME=/jdk1.8.0_74 -e PATH=$PATH:/jdk1.8.0_74/bin registry:8082/$artifactId:$pomVersion"
    withDockerRegistry(credentialsId: 'c4591403-3ffb-4e1b-8231-cfb132fdb14f', url: 'http://registry:8082') {
        sh "docker run -t -d -p 8888:8080 --name $artifactId --restart=always --privileged -v /usr/local/tomcat/conf:/home/docker/$artifactId/conf  -e JAVA_HOME=/jdk1.8.0_74 -e PATH=$PATH:/jdk1.8.0_74/bin registry:8082/$artifactId:$loctag"
    }
}

def defDeployTRIAL(String trialLabel){
    echo "delpy $trialLabel."
}

def defDeployQAT(){
    echo "delpy QAT."
}

def defDeployUAT(){
    echo "delpy UAT."
}

def defConfirmDeployRL(){
    script {
        timeout(time: 5, unit: 'DAYS') {
            input('確定發佈至PROD區域?')
        }
    }
    echo "delpy RL."
}
