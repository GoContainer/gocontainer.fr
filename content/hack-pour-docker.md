---
author: Alexei Ledenev
avatar: https://codefresh.io/wp-content/uploads/2016/12/photo-bw-150x150.jpg
social:
  github: alexei-led
  twitter: alexeiled

banner: "article/hack-pour-docker/placeholder.png"
categories:
- docker
date: 2017-02-20T16:56:43+02:00
menu: ""
tags:
- docker
- hack
title: Hack pour docker
---
Dans ce post, j'ai décidé de partager avec vous quelques commandes et outils utiles que j'utilise fréquemment lorsque je travaille avec docker. 
Il n'y a pas d'ordre particulier ou de «niveau de nouveauté» pour chaque «hack». Je vais simplement présenter le cas d'utilisation et la façon dont la commande spécifique ou 
l'outil m'a aidé avec mon travail.

![docker Animals](/article/hack-pour-docker/docker_animals.png)

# Nettoyage 

Après avoir travaillé avec docker pendant un certain temps, vous commencez à accumuler de nombreux volumes, réseaux, conteneurs et images inutilisées.

## Une commande pour «les gouverner tous»

```BASH 
docker system prune
```   
Prune est une commande très utile (fonctionne aussi pour les sous-commandes de volume et de réseau), mais elle n'est disponible que pour docker 1.13. 
Donc, si vous utilisez des versions docker plus anciennes, les commandes suivantes peuvent vous aider à remplacer la commande prune.

## Supprimer les volumes de dangling

Les volumes en "dangling" sont des volumes qui ne sont pas utilisés par aucun conteneur.
Pour les supprimer, combinez deux commandes: d'abord, listez les ID de volume pour les volumes suspendus, puis supprimez-les.

```BASH
docker rm $ (volume du docker ls -q -f "dangling=true")
```  

## Supprimer les conteneurs sortis

Le même principe fonctionne ici aussi. Tout d'abord, listez les conteneurs (uniquement les ID) que vous voulez supprimer (avec filtre) puis supprimez-les 
(utilisez rm -f pour forcer la suppresion).

```BASH
docker rm $ (docker ps -q -f "status=exited")
```

## Supprimer Dangling Images

Les images dangling sont des images non marquées, qui sont les feuilles de l'arbre des images (pas des couches intermédiaires).

```BASH
docker rmi $ (images docker -q -f "dangling=true")
```

## Autoremove Interactive Containers

Lorsque vous exécutez un nouveau conteneur et que vous souhaitez éviter de taper la commande rm après sa sortie, utilisez l'option -rm. 
Ensuite, lorsque vous sortez du conteneur créé, il sera automatiquement détruit.

```BASH
docker run -it --rm alpine sh
```

## Inspecter les ressources de docker

Jq est un processeur léger et flexible de ligne de commande JSON. C'est comme sed pour les données JSON. Vous pouvez l'utiliser pour découper, filtrer, cartographier et 
transformer des données structurées avec la même facilité que sed, awk, grep.

Les commandes docker info et docker inspect permmettent de retourner leur résultat en JSON, vous pouvez donc le combinez avec la commande jq.

```BASH
# Voir toute les informations
$ docker info --format "{{json.}}" | Jq.

# Voir seulement les plugins
$ docker info --format "{{json .Plugins}}" | Jq.

# Liste des adresses IP pour tous les conteneurs connectés au réseau 'bridge'
$ docker network inspecter bridge -f '{{json .Containers}}' | Jq '. [] | {Cont: .Name, ip: .IPv4Address} '
```

## Affichez une table avec 'ID Image Status' pour les conteneurs actifs et actualisez-le toutes les 2 secondes

```BASH
watch -n 2 'docker ps --format "table {{.ID}} \ t {{.Image}} \ t {{.Status}}"
```

## Entrez dans le namespace de l'Host / Container

Parfois, vous souhaitez vous connecter à l'hôte Docker. La commande ssh est l'option par défaut, mais cette option peut ne pas être disponible, en raison des paramètres de sécurité, des règles de pare-feu ou autre.   
[NScenter](https://github.com/jpetazzo/nsenter), de Jérôme Petazzoni, est un petit outil très utile pour ces cas d'utilisation. La commande nsenter vous permet de saisir des namespaces. J'aime utiliser l'image minimaliste (580 kB) walkerlee / nsenter docker.

## Entrer dans l'hôte docker

Vous pouvez utiliser --pid=host pour entrer dans les namespaces d'hôtes docker.

```
# Obtenir un shell dans l'hôte docker
docker run --rm -it --privileged --pid = hôte walkerlee/nsenter -t 1 -m -u -i -n sh
```
## Entrez dans tous les container

Il est également possible d'entrer dans n'importe quel conteneur avec nsenter et --pid=container:[id OR name]. Mais dans la plupart des cas, il vaut mieux utiliser la commande ```docker exec``. La principale différence est que nsenter n'entre pas dans les cgroups, et évite donc les limitations de ressources (ce qui peut être utile pour le débogage).

```
# Obtenir un shell dans l'espace de noms de conteneur 'redis'
docker run --rm -it --privileged --pid=conteneur:redis walkerlee/nsenter -t 1 -m -u -i -n sh
```

## Créez un conteneur avec l'outil "htop"

```BASH
docker build -t htop - << EOF
FROM alpine
RUN apk --no-cache ajouter htop
EOF
```

## Auto-completion

La syntaxe de la CLI de docker est très riche et en croissance constante: ajout de nouvelles commandes et de nouvelles options. Il est difficile de se souvenir de toutes les commandes possibles et l'option, donc avoir une auto-complétion est un must have.

L'auto-complétion vous permet de compléter automatiquement ou de suggérer automatiquement ce que vous tapez en appuyant sur la touche tabulation. L'auto-complétion de docker fonctionne pour les commandes et les options. 
L'auto-complétion est disponible pour :   
- docker
- docker-machine
- docker-compose  

Si vous êtes un utilisateur de macOS, l'installation est très simple et rapide avec homebrew.

```BASH
$ brew tap homebrew / complétions

$ brew install docker-completion
$ brew install docker-compose-completion
$ brew install docker-machine-completion
```

Si vous n'utilisez pas Mac, lisez la documentation officielle de docker pour l'installation.

## Démarrer les conteneurs automatiquement

Lors de l'exécution d'un processus à l'intérieur d'un conteneur docker, une défaillance peut survenir en raison de plusieurs raisons. 
Dans certains cas, vous pouvez le corriger en réactivant le conteneur défaillant. Si vous utilisez un moteur d'orchestration docker, comme Swarm ou Kubernetes, le service défaillant sera redémarré automatiquement.
Dans le cas contraire, vous pouvez redémarrer le conteneur en fonction du code de sortie du processus principal du conteneur ou toujours le redémarrer (quel que soit le code de sortie). 
docker 1.12 a introduit la commande docker run: ```restart``` pour ce cas d'utilisation.

## Redémarrer toujours

Redémarrez le conteneur redis peut importe le code d'erreur.

```BASH
docker run --restart=always redis
```

## Redémarrer conteneur sur échec

Redémarrez le conteneur redis seulement si il est en échec et pas plus de 10 fois.

```BASH
docker run --restart=on-failure:10 redis
```

## Trucs de réseau

Il peut arriver que vous souhaitiez créer un nouveau conteneur et le connecter à une pile réseau existante. Il peut s'agir du réseau hôte docker ou du réseau d'un autre conteneur. Cela est utile lors du débogage et de l'audit des problèmes réseau.
L'option docker --network/net vous permet de le faire.

## Utiliser le réseau de l'hôte docker

```BASH
docker run --net=host ...
```

Le nouveau conteneur s'attachera aux mêmes interfaces réseau que l'hôte docker.

## Utiliser le réseau d'un autre conteneur

```BASH
docker run --net=container:<nom | id> ...
```

Le nouveau conteneur s'attache aux mêmes interfaces réseau que l'autre conteneur. Le conteneur cible peut être spécifié par id ou nom.

[Source](https://codefresh.io/blog/everyday-hacks-docker/)