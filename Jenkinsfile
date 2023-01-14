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
    // git rev-list --all
    // git log
    // https://jenkins.dev.darey.io/env-vars.html/
    // https://www.jenkins.io/doc/book/pipeline/syntax/#when
    // https://www.jenkins.io/doc/pipeline/steps/pipeline-input-step/
    // Install gitversion https://gitversion.net/docs/usage/cli/installation
    COMMIT_HASH = sh(returnStdout: true, script: 'git rev-parse --short=4 HEAD').trim()
    DOCKER_REGISTRY = "dareyregistry"
    VERSION = "Major"
    // BRANCH = "${env.GIT_BRANCH}"
    // TAG = "${env.BRANCH}.${env.COMMIT_HASH}.${env.BUILD_NUMBER}".drop(15)
    // DEV_TAG = "${env.BRANCH}.${env.COMMIT_HASH}.${env.BUILD_NUMBER}".drop(7)
    // VERSION = "${env.TAG}"
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
      when { tag "release-*" }
      steps {
        container('docker') {
          script {
            def userInput = input(
              id: 'userInput', message: 'Let\'s promote?', parameters: [
              [$class: 'TextParameterDefinition', defaultValue: 'Patch', description: 'The Version Type to Release', name: 'ReleaseVersionType']
            ])
          }
          sh 'docker build -t ${DOCKER_REGISTRY}/java-dashboard:dev-${COMMIT_HASH} .'
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
     stage('Push-image-to-docker-registry on Feature Branch') {
      when { 
        anyOf { branch 'feature/*';} 
        }
      steps {
        container('docker') {
          sh 'docker push ${DOCKER_REGISTRY}/java-dashboard:feature-${COMMIT_HASH}'
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

     stage('Push-image-to-docker-registry on Develop Branch') {
      when { branch 'develop'}
      steps {
        container('docker') {
          sh 'docker push ${DOCKER_REGISTRY}/java-dashboard:dev-${COMMIT_HASH}'
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
