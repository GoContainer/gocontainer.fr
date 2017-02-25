---
author: Jérémy Gréaux
avatar: https://avatars2.githubusercontent.com/u/1903212?v=3&s=460
social:
  github: jeremygreaux
  twitter: jeremygreaux

banner: "article/docker-swarm-scaleway/placeholder.png"
categories:
- docker
date: 2017-02-25T12:56:43+02:00
menu: ""
tags:
- docker
- swarm
- scaleway
title: Création d'un cluster docker swarm avec scaleway
---
Le but de cet article est de vous montrer comment créer votre premier cluster docker swarm avec [Scaleway](https://www.scaleway.com/)  
Si vous ne maitrisez pas docker swarm, ce post est pour vous, sinon passez votre chemin ^^.  

## Les prérequis

Au cours de ce petit tuto, vous aurez besoin d'avoir :  
 - Un compte [scaleway](https://cloud.scaleway.com)  

## Introduction 

Comme je vous le disais, nous allons mettre en place un superbe petit cluster avec docker swarm, mais pourquoi en utiliser un ?  
Il y'a deux raisons assez simples :  
 - Pour assurer une forte disponibilité de nos conteneurs    
 - Permettre une gestion plus simple des conteneurs  
 
Afin de réaliser notre tuto, nous devons dans un premier temps ajouter des machines (instances).  
Pour réaliser un cluster, nous avons théoriquement besoin de n'avoir qu'une seule machine, mais cela n'aurait pas beaucoup d'intérêt, donc nous allons créer 3 instances Scaleway. 
Il est bien sûr possible d'utiliser un autre provider ou même de le faire en local, mais ce n'est pas le but de ce tuto.
Pour cela, allez sur scaleway, et prenez un nouveau serveur et configurez le comme la photo ci-dessous:

![docker configuration scaleway](/article/docker-swarm-scaleway/configuration-server-scaleway.png)

Reproduisez cela deux fois de plus en changeant le nom du serveur par respectivement ``slave-01``et ``slave-02``

## Création du cluster swarm 

À ce stade, nous avons trois instances nommées :  
- ``master``  
- ``slave-01``  
- ``slave-02``  

Les trois instances sont identiques, seuls les noms changent pour le moment.  
Connectez-vous à master. Une fois celà fait, nous allons initialiser notre cluster avec cette commande:

```bash 
 sudo apt upgrade && sudo apt update
 docker swarm init
```

Vous devriez avoir un retour qui, avec une commande docker, ressemble à ça :   

```bash
docker swarm join \
    --token SWMTKN-1-4k0lu04tuc9e8pd44cs8fz24pq386xhi11qz0ti3hdsxspshr2-8t9v1d9tgqiwbxqmtha8zynme \
    10.2.16.197:2377
```

Lorsque vous avez fait le init, il a déclaré votre instance en tant que master et il a ensuite généré un token de sécurité.  
Grâce à ce token, vous pouvez associer à un master des slaves.
A la toute fin, vous avez 10.2.16.197:2377 qui est l'ip du master de votre cluster docker swarm que vous venez de créer.  
Maintenant, vous pouvez vous connecter sur vos 2 autres instances et lancer les commandes ci-dessous:   

```bash 
 sudo apt upgrade && sudo apt update
 docker swarm join \
     --token SWMTKN-1-4k0lu04tuc9e8pd44cs8fz24pq386xhi11qz0ti3hdsxspshr2-8t9v1d9tgqiwbxqmtha8zynme \
     10.2.16.197:2377
```
Voilà, vous venez de lier au master vos slaves. Retournez sur votre master, et lancez la commande **``docker node ls``**. Vous devriez avoir quelque chose comme cela :  

```bash 
 ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
 cw06z79p9ec23t839dcnuoz7s    slave-01  Ready   Active
 hq58gsqla4gbjw3r93fsz5vks    slave-02  Ready   Active
 np6evchytoowphk0uck5on8lp *  master    Ready   Active        Leader
```

Voilà, vous savez maintenant créer un docker swarm, c'est facile non ?
Maintenant, si vous devez ajouter 50 machines à votre cluster, cela reste simple, mais prends beaucoup de temps.  

Nous verrons une solution possible à ce problème dans un autre article :D.

Avant de finir, je vous conseille d'éteindre toutes les instances créées au cours de ce tuto pour ne pas avoir de surpise à la fin du mois.

À la prochaine

