pipeline {
  agent any
  environment {
    DOCKER_IMAGE = "react-nginx"
    DOCKER_TAG = "latest"
    DOMAIN = "dev.4xexch.com"
    EMAIL = "sourbhupadhayay@gmail.com"
    WEBROOT = "/usr/share/nginx/html"
  }
  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/sourabhupadhayay/React-ssl.git'
      }
    }

    stage('Build React') {
      steps {
        dir('react-demo') {
          sh 'npm install'
          sh 'npm run build'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $DOCKER_IMAGE:$DOCKER_TAG .'
      }
    }

    stage('Run Temporary Nginx') {
      steps {
        sh '''
      docker stop temp-nginx || true
      docker rm temp-nginx || true

      # Free up port 80
      CONTAINER_USING_PORT=$(docker ps --filter "publish=80" --format "{{.ID}}")
      if [ -n "$CONTAINER_USING_PORT" ]; then
        docker stop "$CONTAINER_USING_PORT"
      fi

      docker run -d --name temp-nginx -p 80:80 \
        -v /usr/share/nginx/html:/usr/share/nginx/html \
        nginx:alpine
    '''
  }
}


   stage('Run Certbot') {
    steps {
    writeFile file: 'certbot-setup.sh', text: '''#!/bin/bash
DOMAIN="dev.4xexch.com"
EMAIL="sourbhupadhayay@gmail.com"

# Stop containers that bind to port 80
docker ps --filter "publish=80" --format "{{.ID}}" | xargs -r docker stop

docker run --rm -p 80:80 \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /var/lib/letsencrypt:/var/lib/letsencrypt \
  certbot/certbot certonly --standalone \
  -d "$DOMAIN" --agree-tos --email "$EMAIL" --non-interactive
'''
      sh 'chmod +x certbot-setup.sh'
      sh './certbot-setup.sh'
  }
}



    stage('Stop Temporary Nginx') {
      steps {
        sh '''
          docker stop temp-nginx || true
          docker rm temp-nginx || true
        '''
      }
    }

    stage('Run HTTPS Container') {
      steps {
        sh '''
          docker stop react-nginx || true
          docker rm react-nginx || true

          docker run -d --name react-nginx -p 80:80 -p 443:443 \
            -v /etc/letsencrypt/live/$DOMAIN/fullchain.pem:/etc/nginx/ssl/fullchain.pem:ro \
            -v /etc/letsencrypt/live/$DOMAIN/privkey.pem:/etc/nginx/ssl/privkey.pem:ro \
            $DOCKER_IMAGE:$DOCKER_TAG
        '''
      }
    }

    stage('Update DNS') {
      steps {
        sh './update-dns.sh'
      }
    }

    stage('Verify HTTPS') {
      steps {
        sh 'curl -I https://$DOMAIN --resolve $DOMAIN:443:127.0.0.1 --insecure'
      }
    }
  }
}
