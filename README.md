# AWS High Availability Architecture with Terraform

Infrastructure réseau AWS conçue avec **Terraform**, organisée sur plusieurs zones de disponibilité (*Availability Zones*) et pensée pour évoluer vers une architecture applicative hautement disponible.

## 🎯 Objectif du projet

Ce projet consiste à concevoir et provisionner une infrastructure AWS reproductible à l'aide de l'Infrastructure as Code (IaC).

L'objectif est de mettre en place une base réseau sécurisée, de séparer les ressources publiques et privées, puis de préparer l'infrastructure à accueillir une application distribuée sur plusieurs zones de disponibilité.

## 🏗️ Architecture actuelle

L'infrastructure déployée comprend :

- Un **Amazon VPC** avec le CIDR `10.0.0.0/16`.
- Deux sous-réseaux publics répartis sur deux zones de disponibilité.
- Deux sous-réseaux privés répartis sur les mêmes zones.
- Un **Internet Gateway** pour la connectivité Internet des sous-réseaux publics.
- Des tables de routage distinctes pour les sous-réseaux publics et privés.
- Des groupes de sécurité préparant la séparation entre le futur load balancer et les instances applicatives.
- Une configuration gérée par Terraform.

### Plan d'adressage IP

| Ressource | CIDR | Zone de disponibilité |
|---|---|---|
| VPC | `10.0.0.0/16` | Région `us-east-1` |
| Public subnet 1 | `10.0.1.0/24` | `us-east-1a` |
| Public subnet 2 | `10.0.2.0/24` | `us-east-1b` |
| Private subnet 1 | `10.0.11.0/24` | `us-east-1a` |
| Private subnet 2 | `10.0.12.0/24` | `us-east-1b` |

## 🛠️ Technologies utilisées

- **Cloud provider :** Amazon Web Services (AWS)
- **Infrastructure as Code :** Terraform
- **Networking :** VPC, subnets, route tables, Internet Gateway
- **Security :** Security Groups
- **Version control :** Git et GitHub

## 🔐 Choix d'architecture et de sécurité

- Séparation des sous-réseaux publics et privés.
- Répartition sur deux zones de disponibilité pour préparer la résilience.
- Absence de route Internet directe dans les sous-réseaux privés.
- Préparation d'un filtrage réseau entre le futur Application Load Balancer et les instances applicatives.
- Aucun accès SSH public n'est ouvert par les groupes de sécurité créés dans cette étape.

**Note :** les sous-réseaux privés ne disposent pas actuellement de NAT Gateway. Les ressources qui y seront déployées n'auront donc pas de sortie Internet IPv4 directe via cette architecture.

## 🚀 Déploiement

### Prérequis

- Un compte AWS avec les autorisations nécessaires.
- AWS CLI configuré.
- Terraform installé.
- Git installé.

### 1. Cloner le dépôt

```bash
git clone https://github.com/kmbamba/aws-ha-architecture.git
cd aws-ha-architecture
```

### 2. Initialiser Terraform

```bash
terraform -chdir=terraform init
```

### 3. Vérifier la configuration

```bash
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
```

### 4. Prévisualiser les changements

```bash
terraform -chdir=terraform plan
```

### 5. Appliquer la configuration

```bash
terraform -chdir=terraform apply
```

Examine toujours le plan avant de confirmer l'application.

## 🧪 Vérifications effectuées

- Initialisation et validation de la configuration Terraform.
- Provisionnement du VPC et des sous-réseaux.
- Création de l'Internet Gateway et de la table de routage publique.
- Association des sous-réseaux publics et privés à leurs tables respectives.
- Vérification des routes AWS avec AWS CLI.
- Vérification de la cohérence entre l'infrastructure et la configuration Terraform.

## 💰 Gestion des coûts AWS

Ce projet est développé dans une optique d'apprentissage et de maîtrise des coûts.

- Aucun NAT Gateway n'est déployé à ce stade.
- L'Application Load Balancer et les instances EC2 ne font pas encore partie de l'infrastructure déployée.
- Avant d'ajouter des ressources facturables, vérifiez les tarifs AWS, les crédits disponibles et les éventuelles restrictions du compte.
- Après les tests, vérifiez le plan Terraform avant toute destruction de ressources.

## 🗺️ Évolutions prévues

- [ ] Ajouter un Application Load Balancer réparti sur les deux sous-réseaux publics.
- [ ] Déployer des instances applicatives dans les sous-réseaux privés.
- [ ] Configurer un Auto Scaling Group pour améliorer la disponibilité.
- [ ] Tester la résilience en cas d'indisponibilité d'une instance.
- [ ] Ajouter la supervision et les alertes.
- [ ] Étudier une stratégie de reprise après sinistre multi-région.
- [ ] Ajouter un schéma d'architecture détaillé.

## 👨‍💻 Auteur

**Khadim Mbaye**  
Cloud & DevOps | AWS | Terraform | Infrastructure as Code

- GitHub : [@kmbamba](https://github.com/kmbamba)

---

*Projet pédagogique évolutif : les composants indiqués dans les évolutions prévues ne sont pas encore déployés.*