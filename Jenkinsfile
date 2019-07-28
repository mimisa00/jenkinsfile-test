pipeline {
    agent { 
        label 'master'
    }
    tools {
        maven 'mvn-werp'
        jdk 'jdk-werp'
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
                branch 'testing';
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
                defDeployTRIAL('COMMON-TRIAL')
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
    def pomVersion = getPomVer();
    sh "mvn clean install package"
    withDockerRegistry(credentialsId: 'c4591403-3ffb-4e1b-8231-cfb132fdb14f', url: 'http://registry:8082') {
        sh "docker build -t registry:8082/$artifactId:$pomVersion ."
        sh "docker push registry:8082/$artifactId:$pomVersion"
        sh "docker tag registry:8082/$artifactId:$pomVersion registry:8082/$artifactId:latest"
        sh "docker push registry:8082/$artifactId:latest"
    }
}

def getPomArtifactId() {
    return readMavenPom().getArtifactId()
}

def getPomVer() {
    return readMavenPom().getVersion();
}

def defDeploySIT(){
    def artifactId = getPomArtifactId()
    def pomVersion = getPomVer()
    def containerid = sh(script: "docker ps --quiet --filter name=$artifactId", returnStdout: true).trim()
    if (containerid != ''){
        sh "docker stop $artifactId"
        sh "docker rm $artifactId"
    }
    sh "docker run -t -d -p 8888:8080 --name $artifactId --restart=always --privileged -v /usr/local/tomcat/conf:/home/docker/$artifactId/conf  -e JAVA_HOME=/jdk1.8.0_74 -e PATH=$PATH:/jdk1.8.0_74/bin registry:8082/$artifactId:$pomVersion"
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
            input('確定發佈RL版本至PROD區域?')
        }
    }
    echo "delpy RL."
}

def defConfirmDeployPRL(){
    script {
        timeout(time: 1, unit: 'HOURS') {
            input('確定發佈PRL版本至PROD區域?')
        }
    }
    echo "delpy PRL."
}