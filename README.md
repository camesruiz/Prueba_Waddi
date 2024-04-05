# Prueba Waddi

Este repositorio contiene la implementación de un pipeline
de datos. El proceso consiste en la ingestión de los datos
usando una función lambda, el procesamiento, limpieza y
transformación de los datos usando un job de Glue, y por
último, la disponibilización de los datos en una tabla del
Data Catalog.

Toda la orquestación se hace a través de una step function.

## Project Overview

```
PruebaStori
├── .circleci           # CI/CD pipeline
│   ├── config.yml
├── infra               # Terraform files
│   ├── main.tf
│   ├── glue.tf
│   ├── lambda.tf
│   ├── step.tf
│   ├── s3.tf
│   ├── iam.tf
├── glue_script         # glue job code
│   ├── etl.py
├── lambda_script       # Lambda source code
│   ├── lambda_function.py
├── test                # Unit testing functions
│   ├── __init__.py
│   ├── test_lambda_function.py
├── .gitignore
└── README.md
```