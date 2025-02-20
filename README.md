 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/intersystems-iris-dev-template)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fintersystems-iris-dev-template&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fintersystems-iris-dev-template)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Fintersystems-iris-dev-template&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Fintersystems-iris-dev-template)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)

# documentservice
Demonstrates how to handle large Streams in JSON using InterSystems ObjectScript.

It it the code for the intersystems community article 

https://es.community.intersystems.com/post/servicio-rest-para-carga-y-descarga-de-documentos-largos



## Quick Start

Download the repository with

```
$git clone https://github.com/es-comunidad-intersystems/documentservice
```

Start the Server with

```
$docker compose up -d
```

Setup the python virtual environment and run the python clients to upload a file and download it again

```
cmd:>cd client
cmd:>setup_env.bat
cmd:>runpost.bat
cmd:>runget.bat
```

