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
