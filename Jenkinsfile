pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: maven
            image: maven:alpine
            command:
            - cat
            tty: true
          - name: docker
            image: docker:latest
            command:
            - cat
            tty: true
            volumeMounts:
             - mountPath: /var/run/docker.sock
               name: docker-sock
          volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock    
        '''
    }
  }

  environment {
    // git rev-list --all
    // git log
    // https://jenkins.dev.darey.io/env-vars.html/
    COMMIT_HASH = sh(returnStdout: true, script: 'git rev-parse --short=4 HEAD').trim()
    BRANCH = "${env.GIT_BRANCH}"
    TAG = "${env.BRANCH}.${env.COMMIT_HASH}.${env.BUILD_NUMBER}".drop(15)
    DEV_TAG = "${env.BRANCH}.${env.COMMIT_HASH}.${env.BUILD_NUMBER}".drop(7)
    VERSION = "${env.TAG}"
}

  stages {

    stage("list environment variables") {
            steps {
                sh "printenv | sort"
                echo "${DEV_TAG}.latest"
                script{
                    if (BRANCH.contains ('origin/develop')) {
                        echo 'branch is develop'
                        $VERSION = "${env.DEV_TAG}.latest"]
                        echo "${env.VERSION}"
                    }
                }
            }
        }

    stage('Build-Jar-file') {
      steps {
        container('maven') {
          sh 'mvn package'
        }
      }
    }

    stage('Unit-Test') {
        steps {
          container('maven') {
            sh 'mvn test'
         }
        }
        post {
            always {
                junit 'target/surefire-reports/*.xml'
            }
        }
    }

    stage('Build-Docker-Image') {
      steps {
        container('docker') {
          sh 'docker build -t dareyregistry/java-dashboard:latest .'
        }
      }
    }

		stage('Docker Login') {

			steps {
        container('docker') {
        withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'Docker_registry_password', usernameVariable: 'Docker_registry_user')]) {
            sh 'docker login -u $Docker_registry_user -p $Docker_registry_password'
        }
		  }
     }
    }
     stage('Push-image-to-docker-registry') {
      steps {
        container('docker') {
          sh 'docker push dareyregistry/java-dashboard:latest'
      }
    }
    post {
      always {
        container('docker') {
          sh 'docker logout'
      }
      }
    }
  }
 }
}
