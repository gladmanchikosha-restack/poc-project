pipeline {
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
                sh 'mvn clean deploy'
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
    }
}