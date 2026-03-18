# Getting Started

### Reference Documentation

For further reference, please consider the following sections:

* [Official Apache Maven documentation](https://maven.apache.org/guides/index.html)
* [Spring Boot Maven Plugin Reference Guide](https://docs.spring.io/spring-boot/4.0.3/maven-plugin)
* [Create an OCI image](https://docs.spring.io/spring-boot/4.0.3/maven-plugin/build-image.html)
* [HTTP Client](https://docs.spring.io/spring-boot/4.0.3/reference/io/rest-client.html#io.rest-client.restclient)
* [Spring Web](https://docs.spring.io/spring-boot/4.0.3/reference/web/servlet.html)
* [Spring Reactive Web](https://docs.spring.io/spring-boot/4.0.3/reference/web/reactive.html)

### Guides

The following guides illustrate how to use some features concretely:

* [Building a RESTful Web Service](https://spring.io/guides/gs/rest-service/)
* [Serving Web Content with Spring MVC](https://spring.io/guides/gs/serving-web-content/)
* [Building REST services with Spring](https://spring.io/guides/tutorials/rest/)
* [Building a Reactive RESTful Web Service](https://spring.io/guides/gs/reactive-rest-service/)

### Maven Parent overrides



Due to Maven's design, elements are inherited from the parent POM to the project POM.
While most of the inheritance is fine, it also inherits unwanted elements like `<license>` and `<developers>` from the
parent.
To prevent this, the project POM contains empty overrides for these elements.
If you manually switch to a different parent and actually want the inheritance, you need to remove those overrides.

Step 1: Containerize Your Application and Push to Artifact Registry
First, package your Spring Boot application as a Docker image and push it to GCP's Artifact Registry:
Enable the Artifact Registry API
$gcloud services enable artifactregistry.googleapis.com
Configure Docker authentication for Artifact Registry:
$gcloud auth configure-docker us-central1-docker.pkg.dev
get GCP project
$export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value project)
Using a Dockerfile and Docker commands:
Build docker image
 (Assuming you have a Dockerfile in your project root)

# us-central1-docker.pkg.dev/spring-boot-demo-490202/container-registry
$docker build -t us-central1-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/container-registry/my-spring-app:latest .

Check local docker images
$ docker images
Push docker image to the artifact repo:
$docker push us-central1-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/container-registry/my-spring-app:latest
Provision a Kubernetes cluster in GKE where your application will ru
$gcloud container clusters create spring-boot-cluster --zone us-central1-c

Check clusters in project:
$gcloud container clusters list

Once the cluster is ready, get the credentials for kubectl to connect to it:
$gcloud container clusters get-credentials spring-boot-cluster --zone us-central1-c

Create YAML files to define the Kubernetes Deployment and Service for your application.
deployment.yaml: Manages the stateless application pods
----------------------------------
apiVersion: apps/v1
kind: Deployment
metadata:
name: spring-boot-deployment
spec:
selector:
matchLabels:
app: spring-boot-app
replicas: 2
template:
metadata:
labels:
app: spring-boot-app
spec:
containers:
- name: spring-boot-container
image: us-central1-docker.pkg.dev/spring-boot-demo-490202/container-registry/my-spring-app:latest # Replace with your image path
ports:
- containerPort: 8080 # Default Spring Boot port

--------------------------------
service.yaml: Exposes the application to the internet via a LoadBalancer service
--------------------

apiVersion: v1
kind: Service
metadata:
name: spring-boot-service
spec:
selector:
app: spring-boot-app
type: LoadBalancer # GKE will provision a GCP load balancer
ports:
- protocol: TCP
  port: 80
  targetPort: 8080
-----------------------------------------

Step 4: Deploy to GKE
Apply your YAML manifests using kubectl
$kubectl apply -f deployment.yaml
$kubectl apply -f service.yaml

Monitor the deployment status until the pods are running: 
$kubectl rollout status deployment/spring-boot-deployment

Step 5: Access Your Application
Once the service is deployed (this may take a few minutes for the LoadBalancer to provision), you can get the external IP address: 
$ kubectl get service spring-boot-service
run curl to  get the response from the service
$%curl http://34.44.80.243:80/hello
Hello, World from Gary test!


Install Jenkins

$brew install jenkins-lts



Start the Jenkins Service

$brew services start jenkins-lts
Access the Dashboard: Open your web browser and navigate to http://localhost:8080

To allow GitHub to trigger builds on your local Jenkins instance, GitHub's servers must be able to reach your Mac. Since localhost is only accessible from your own machine, you can use a tunneling tool like ngrok to create a temporary, public URL that forwards traffic to your local Jenkins port

$brew install ngrok/ngrok/ngrok
Start a Tunnel: Run the following command in your Terminal (replace 8080 if your Jenkins uses a different port):
$ngrok config add-authtoken 3B6qHXOgTU7qLcwCTIVGi9F1cfT_2yXjBZAPG9zXKvWJgxcCc
$ngrok http 8080

Copy the Forwarding URL: Look for the line starting with Forwarding. It will look something like https://a1b2-c3d4.ngrok-free.app. Keep this Terminal window open; if you close it, the tunnel will disconnect.
2. Update Jenkins Configuration
   In Jenkins, go to Manage Jenkins > System.
   Find the Jenkins URL field.
   Replace http://localhost:8080/ with your new ngrok URL (e.g., https://a1b2-c3d4.ngrok-free.app).

3. Add the Webhook to GitHub
   Go to your GitHub repository and click Settings > Webhooks > Add webhook.
   BlazeMeter
   Payload URL: Paste your ngrok URL and append /github-webhook/.
   Medium
   Example: https://a1b2-c3d4.ngrok-free.app/github-webhook/.
   Content type: Select application/json.
   Which events?: Select Just the push event (or customize as needed). 




Step 1: Create Service Account (GCP) ( for jenkins)
Go to IAM & Admin → Service Accounts
Click Create Service Account
Name: jenkins-deployer

Step 2: Assign Required Roles
For GKE + Artifact Registry, assign:
Kubernetes Engine Admin
Artifact Registry Writer
Storage Admin (optional, if using legacy registry)

Step 3: Download JSON Key
Click your service account
Go to Keys tab
Click Add Key → Create new key
Choose JSON
Download file (e.g., jenkins-gcp-key.json)

Step 4: Add JSON Key to Jenkins
In Jenkins:
Go to:
Manage Jenkins → Credentials → Global → Add Credentials
Choose:
Kind: Secret file
Upload: your JSON file
ID: gcp-key ✅ (used in pipeline)
Description: GCP Service Account

step 5:
In pipeline configuration set Trigger to 
GitHub hook trigger for GITScm polling


