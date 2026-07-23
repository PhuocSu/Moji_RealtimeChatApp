## Overview
MojiChatApp (fork) is a project that demonstrates the application of DevSecOps and Infrastructure as Code in modern software development workflows. Instead of focusing on building chat features, this fork emphasizes designing automated CI/CD pipelines, integrating security testing, and managing infrastructure with tools such as Terraform and Docker Swarm. The goal is to create a secure, scalable, and efficient deployment environment, showcasing how DevSecOps and IaC can enhance quality and operational effectiveness for any application.

## Web Development Technologies & Deployment Technologies
![Express.js](https://img.shields.io/badge/Express.js-008000?logo=express&logoColor=white&style=for-the-badge)
![React.js](https://img.shields.io/badge/React.js-61DAFB?logo=react&logoColor=black&style=for-the-badge)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?logo=mongodb&logoColor=white&style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white&style=for-the-badge)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?logo=prometheus&logoColor=white&style=for-the-badge)
![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&logoColor=white&style=for-the-badge)

## Infrastructure Technologies & Automation Technologies
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white&style=for-the-badge)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?logo=ansible&logoColor=white&style=for-the-badge)
![Vagrant](https://img.shields.io/badge/Vagrant-1563FF?logo=vagrant&logoColor=white&style=for-the-badge)
![Jenkins](https://img.shields.io/badge/Jenkins-D24939?logo=jenkins&logoColor=white&style=for-the-badge)
![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white&style=for-the-badge)


## 🏛️Interface
![alt text](assets/screenshots/README-${unique}-1.png)
![alt text](assets/screenshots/README-${unique}-2.png)
![alt text](assets/screenshots/README-${unique}-3.png)

## 🏛️Infrastructure Architecture
- Development Architecture
![alt text](assets/screenshots/MojiChatApp-DevSecOps&IaC.drawio.svg)
### Virtual Machine Specifications
![alt text](assets/screenshots/README-${unique}-4.png)
### Pipeline Jobs Specifications
![alt text](assets/screenshots/README-${unique}-21.png)
## Pipelines
### Jenkins jobs
![alt text](assets/screenshots/README-${unique}-5.png)
#### Deploy-stack
![alt text](assets/screenshots/README-${unique}-20.png)
#### Destroy-stack
![alt text](assets/screenshots/README-${unique}-7.png)
#### Health-check
![alt text](assets/screenshots/README-${unique}-19.png)
#### Setup VMs
![alt text](assets/screenshots/README-${unique}-18.png)
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
