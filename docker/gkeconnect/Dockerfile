#Use the Alpine base image for gcloud sdk. 
FROM google/cloud-sdk:alpine

# Install Kubectl
RUN gcloud components install kubectl

#Install Terraform 
#We are installing the current latest stable version 0.13.5
RUN wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip \
&& unzip terraform_0.13.5_linux_amd64.zip && rm terraform_0.13.5_linux_amd64.zip \
&& mv terraform /usr/bin/terraform

#Install K9s
RUN wget -c https://github.com/derailed/k9s/releases/download/v0.22.1/k9s_Linux_x86_64.tar.gz -O - | tar -xz && chmod +x k9s && mv k9s /usr/local/bin

#Inject the service account key file into the image.
RUN mkdir webapps
COPY . /webapps
