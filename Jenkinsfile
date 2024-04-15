pipeline {
    agent |{label 'maven'}

    environment {
        PATH = "/opt/apache-maven-3.9.6/bin:$PATH"
    }


    stages {
        stage('Clone') {
            steps {
                git branch: 'main' url: 'https://github.com/gladmanchikosha-restack/poc-project.git'
            }
        }

        stage('build'){
            steps {
                sh 'mvn clean deploy'
            }
        }
    }
}