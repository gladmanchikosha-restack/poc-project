pipeline {
    def registry = 'https://gladman.jfrog.io/'
    agent {label 'maven'}

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

    }
}