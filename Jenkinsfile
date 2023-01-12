// Here we will introduce conditional logic to determine the actions based on the branch doing the build and push
pipeline {
  agent {
    kubernetes {
      yaml """
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
        """
    }
  }

  environment {
    COMMIT_HASH = sh(returnStdout: true, script: 'git rev-parse --short=4 HEAD').trim()
    DOCKER_REGISTRY = "dareyregistry"
}

  stages {


    stage('Git Tagging') {
      steps {
        sh '''
              git fetch --tags
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
                echo "New Version new_version"
                new_version="$major.$minor.$patch"

                # Create a new tag for the new version
                git tag -a "$new_version" -m "Release $new_version"

                # Push the new tag to the remote repository
                git push --tags

        '''
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
      when { branch "release-*" }
      steps {
        container('docker') {
          script {
            def userInput = input(
              id: 'userInput', message: 'Let\'s promote?', parameters: [
              [$class: 'TextParameterDefinition', defaultValue: 'Patch', description: 'The Version Type to Release', name: 'ReleaseVersionType']
            ])
          }
          // Notice here that even though we are creating a release TAG, our CI is still using a COMMIT_HASH which is not ideal for production.
          // Hence we will need to introduce a special logic to implement Semantic Versioning got releases. So that Major.Minor.Patch values are dynamically calculated and incremented.
          // For this reason, this pipeline is not ready and we cannot have a stage to release on TAG. Not just yet.
          sh 'docker build -t ${DOCKER_REGISTRY}/java-dashboard:release-${version} .'
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


// In the first stage, 'Build-Jar-file', the Maven container builds a JAR file for the application.

// The second stage, 'Unit-Test', runs the unit tests for the application using Maven, and reports the test results using the JUnit plugin.

// The third stage, 'Build-Docker-Image on Feature branches', builds a Docker image for the application when the code is pushed to a feature branch. The image is tagged with the shortened commit hash and the word "feature".

// The fourth stage, 'Build-Docker-Image on Develop Branch', builds a Docker image for the application when the code is pushed to the develop branch. The image is tagged with the shortened commit hash and the word "dev".

// The fifth stage, 'Build-Docker-Image on Release Tag', builds a Docker image for the application when the code is pushed with a release tag. It prompts the user for input before building the image, and tags the image with the shortened commit hash and the word "release".

// The sixth stage, 'Docker Login', logs in to the Docker registry using credentials stored in Jenkins.

// The seventh stage, 'Push-image-to-docker-registry on Feature Branch', pushes the Docker image built in the third stage to the Docker registry when the code is pushed to a feature branch.

// The eighth stage, 'Push-image-to-docker-registry on Develop Branch', pushes the Docker image built in the fourth stage to the Docker registry when the code is pushed to the develop branch.

// The ninth stage, 'Push-image-to-docker-registry on Release Tag', pushes the Docker image built in the fifth stage to the Docker registry when the code is pushed with a release tag.

// Finally, the 'Deploy-to-kubernetes' stage deploys the application to a Kubernetes cluster using the image pushed to the Docker registry in one of the previous stages.

// Overall, this Jenkinsfile defines a pipeline that builds, tests, and deploys a Java-based application using Maven, Docker, and Kubernetes.