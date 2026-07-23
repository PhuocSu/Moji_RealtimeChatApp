## Overview
MojiChatApp (fork) is a project that demonstrates the application of DevSecOps and Infrastructure as Code in modern software development workflows. Instead of focusing on building chat features, this fork emphasizes designing automated CI/CD pipelines, integrating security testing, and managing infrastructure with tools such as Terraform and Docker Swarm. The goal is to create a secure, scalable, and efficient deployment environment, showcasing how DevSecOps and IaC can enhance quality and operational effectiveness for any application.

## 🏛️Interface
![alt text](assets/screenshots/README-${unique}-1.png)
![alt text](assets/screenshots/README-${unique}-2.png)
![alt text](assets/screenshots/README-${unique}-3.png)

## 🏛️Infrastructure Architecture
- Development Architecture
![alt text](assets/screenshots/README-${unique}-4.png)
### Virtual Machine Specifications
- Coming-soon
## Pipelines
### Jenkins jobs
![alt text](assets/screenshots/README-${unique}-5.png)
#### Deploy-stack
![alt text](assets/screenshots/README-${unique}-6.png)
#### Destroy-stack
![alt text](assets/screenshots/README-${unique}-7.png)
#### Health-check
![alt text](assets/screenshots/README-${unique}-8.png)
#### Setup VMs
![alt text](assets/screenshots/README-${unique}-9.png)
### Github Action jobs
![alt text](assets/screenshots/README-${unique}-10.png)
- With Code Quality scan, we can see in own sonarqube UI.
![alt text](assets/screenshots/README-${unique}-11.png)
- For performance test (k6) and security scanning (ZAP), we can view the artifact results after Github pipeline finished.
![alt text](assets/screenshots/README-${unique}-12.png)
- In my repository, under Security and quality > Code scanning, we can view the results of image scans (Trivy) and dependency vulnerabilities scan (snyk).
![alt text](assets/screenshots/README-${unique}-13.png)
## ⏱️Monitoring
### Grafana
![alt text](assets/screenshots/README-${unique}-14.png)
=> Grafana will monitor the manager node, swarm nodes, and the monitoring services.
### Prometheous
![alt text](assets/screenshots/README-${unique}-15.png)
### Alert Manager
![alt text](assets/screenshots/README-${unique}-16.png)
=> Then Alert Manager will trigger to Slack
![alt text](assets/screenshots/README-${unique}-17.png)
