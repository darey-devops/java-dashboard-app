// This will pass. We now have a good way to use docker containers for each stage of the build. But we are only pushing the latest version each time there is a build
// We have introduced a way to pick up the Docker credentials, so that we can successfully publish the image to our docker registry. Try to use another registry as an excercise. Like Artifactory.
// TODO: We need to separate the stages based on which branch is doing the build and push. Feature. Develop, Main or a release TAG

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
    DOCKER_REGISTRY = "dareyregistry"
}

  stages {

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
          sh 'docker build -t ${DOCKER_REGISTRY}/java-dashboard:latest .'
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
          sh 'docker push ${DOCKER_REGISTRY}/java-dashboard:latest'
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
