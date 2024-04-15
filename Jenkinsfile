//https://dev.to/taikedz/gruelling-groovy-gotchas-loops-closures-and-jenkins-dsls-9pe
def registry = 'https://gladman.jfrog.io/'
def imageName = 'gladman.jfrog.io/valaxy-docker-docker/valaxy-docker-docker/'
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

    }
}


// pipeline {
// 	agent any
// 	tools {
// 		jfrog 'jfrog-cli'
// 	}
// 	environment {
// 		DOCKER_IMAGE_NAME = "gladman.jfrog.io/docker-local/hello-frog:1.0.0"
// 	}
// 	stages {
// 		stage('Clone') {
// 			steps {
// 				git branch: 'master', url: "https://github.com/jfrog/project-examples.git"
// 			}
// 		}

// 		stage('Build Docker image') {
// 			steps {
// 				script {
// 					docker.build("$DOCKER_IMAGE_NAME", 'docker-oci-examples/docker-example')
// 				}
// 			}
// 		}

// 		stage('Scan and push image') {
// 			steps {
// 				dir('docker-oci-examples/docker-example/') {
// 					// Scan Docker image for vulnerabilities
// 					jf 'docker scan $DOCKER_IMAGE_NAME'

// 					// Push image to Artifactory
// 					jf 'docker push $DOCKER_IMAGE_NAME'
// 				}
// 			}
// 		}

// 		stage('Publish build info') {
// 			steps {
// 				jf 'rt build-publish'
// 			}
// 		}
// 	}
// }