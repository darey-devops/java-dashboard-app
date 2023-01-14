// Here we will introduce conditional logic to determine the actions based on the branch doing the build and push
pipeline {
  agent {
    kubernetes {
      yaml """
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: ubuntu
            image: ubuntu:latest
            command:
            - cat
            tty: true
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

        """
    }
  }

  environment {
    COMMIT_HASH = sh(returnStdout: true, script: 'git rev-parse --short=4 HEAD').trim()
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
      when { 
        anyOf { branch 'develop';} }
      steps {
        container('ubuntu') {
          script {
            def userInput = input(
              id: 'userInput', message: 'Set the release type', parameters: [
              [$class: 'TextParameterDefinition', defaultValue: 'Patch', description: 'Accepted valuse must be "Major", "Minor" or "Patch"', name: 'ReleaseVersionType']
            ])
          }
        sh '''
              # Getting the release tag, and creating a bump.
              apt update -y 
              apt install git vim -y
              git config --global --add safe.directory /home/jenkins/agent/workspace/EY.IO_java-dashboard-app_develop
              git fetch --tags
              #sleep 3000
              current_version=$(git describe --tags --abbrev=0)
              echo "Current Version = $current_version"
              # Get the current version numbers
              major=$(echo $current_version | awk -F '.' '{print $1}')
              minor=$(echo $current_version | awk -F '.' '{print $2}')
              patch=$(echo $current_version | awk -F '.' '{print $3}')
              # Set release type
              release_type="patch"
              echo "Release type = $release_type"
              # Bump the version based on the release type
              // if [ "$release_type" == "major" ]; then
              //     major=`expr $major + 1`
              //     minor=0
              //     patch=0
              // elif [ "$release_type" == "minor" ]; then
              //     minor=`expr $minor + 1`
              //     patch=0
              // elif [ "$release_type" == "patch" ]; then
              //     patch=`expr $patch + 1`
              // else
              //     echo "Invalid release type"
              //     exit 1
              // fi
              # Create the new version string
              #new_version="$major.$minor.$patch"
              new_version="1.4.7"
              echo "New Version new_version"

              // # Create a new tag for the new version
              // git tag -a "$new_version" -m "Release $new_version"

              // # Push the new tag to the remote repository
              // git push --tags
        '''
        }
        container('docker') {
          sh 'docker build -t ${DOCKER_REGISTRY}/java-dashboard:release-${new_version} .'
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

     stage('Push-image-to-docker-registry on Release Branch') {
      when { 
        anyOf { branch 'develop';} 
        }
      steps {
        container('docker') {
          sh 'docker push ${DOCKER_REGISTRY}/java-dashboard:feature-${COMMIT_HASH}'
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
