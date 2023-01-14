@Library('dockerSemvarTagging') _
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
          - name: gitversion
            image: gittools/gitversion:5.6.6
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
          - name: repo-clone
            hostPath:
              path: /home/jenkins/agent
        '''
    }
  }

  environment {

    COMMIT_HASH = sh(returnStdout: true, script: 'git rev-parse --short=4 HEAD').trim()
    DOCKER_REGISTRY = "dareyregistry"
    VERSION = "Major"
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

    stage('Build-Docker-Image on Feature branches') {
      when { 
        anyOf { branch 'feature/*';} 
        }
      steps {
        container('docker') {
          sh 'docker build -t ${DOCKER_REGISTRY}/java-dashboard:feature-${COMMIT_HASH} .'
        }
      }
    }

    stage('Build-Docker-Image on Develop Branch') {
      when { branch 'develop'}

      steps {
        container('docker') {
          sh 'docker build -t ${DOCKER_REGISTRY}/java-dashboard:dev-${COMMIT_HASH} .'
        }
      }
    }

    stage('Build-Docker-Image on Release Tag') {
      anyOf { branch 'develop';} 
      stages {
        stage {
          steps {

            container (ubuntu) {
              sh '''
              newversion=1.4.7
              echo "FROM ubuntu step ---> $newversion"
              '''
            }
          }
        }
        stage {
        container('docker') {
          script {
            def userInput = input(
              id: 'userInput', message: 'Let\'s promote?', parameters: [
              [$class: 'TextParameterDefinition', defaultValue: 'Patch', description: 'The Version Type to Release', name: 'ReleaseVersionType']
            ])
          }
          sh 'echo "FROM Docker step ---> $newversion"'
          sh 'docker build -t ${DOCKER_REGISTRY}/java-dashboard:dev-${newversion} .'
         }
        }
      }
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
