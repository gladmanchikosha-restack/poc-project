//https://dev.to/taikedz/gruelling-groovy-gotchas-loops-closures-and-jenkins-dsls-9pe
def registry = 'https://gladman.jfrog.io/'
def imageName = 'gladman.jfrog.io/valaxy-docker-docker-local/gladman'
def version = '2.1.2'
pipeline {
    agent {label 'maven'}
    tools {
		jfrog 'jfrog-cli'
	}
    environment {
        PATH = "/opt/apache-maven-3.9.6/bin:$PATH"
    }

    stages {
        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/gladmanchikosha-restack/poc-project.git'
            }
        }

        stage('build'){
            steps {
                echo "-------------------- build started -------------------- "
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                echo "-------------------- build completed  -------------------- "
            }
        }

        stage('test'){
            steps{
                echo "-------------------- build started -------------------- "
                sh 'mvn surefire-report:report'
                echo "-------------------- build completed  -------------------- "
            }
        }

        stage('SonarQube analysis') {
            environment {
                scannerHome = tool 'sonar-scanner'
            }
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    echo "-------------------- sonarqube anylysis started -------------------- "
                    sh "${scannerHome}/bin/sonar-scanner"
                    echo "-------------------- sonarqube anylysis finished-------------------- "
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure ${qg.status}"
                        }
                    }
                }
            }
        }

        stage("Jar Publish") {
            steps {
                script {
                    // def registry = 'https://gladman.jfrog.io/'
                    echo '<--------------- Jar Publish Started --------------->'
                    def server = Artifactory.newServer url:registry+"/artifactory" , credentialsId:"jfrog-token"
                    def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                    def uploadSpec = """{
                        "files": [
                        {
                        "pattern": "jarstaging/(*)",
                        "target": "poc-test-libs-release/{1}",
                        "flat": "false",
                        "props" : "${properties}",
                        "exclusions": [ "*.sha1", "*.md5"]
                        }
                        ]
                        }"""
                    def buildInfo = server.upload(uploadSpec)
                    buildInfo.env.collect()
                    server.publishBuildInfo(buildInfo)
                    echo '<--------------- Jar Publish Ended --------------->'
                }
            }
        }

        stage('Docker Build'){
            steps{
                script{
                    echo "-------------------- Docker Build Started -------------------- "
                    app = docker.build(imageName+":"+version)
                    echo "-------------------- Docker Build finished-------------------- "
                }
            }
        }

        stage('Docker Publish'){
            steps{
                script{
                    echo "-------------------- Docker Publish Started -------------------- "
                    docker.withRegistry(registry, 'jfrog-token'){
                        app.push()
                    }
                    echo "-------------------- Docker Publish finished-------------------- "
                }
            }
        }

        stage('Deploy'){
            steps{
                script{
                    echo "-------------------- Deployment Started -------------------- "
                    sh './deploy.sh'
                    echo "-------------------- Deployment finished-------------------- "
                }
            }
        }

        stage(" Deploy Helm") {
            steps {
                script {
                    echo '<--------------- Helm Deploy Started --------------->'
                    sh 'helm upgrade --install ttrend ttrend-0.1.0.tgz'
                    echo '<--------------- Helm deploy Ends --------------->'
                }
            }
        }
    }
}