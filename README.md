# jwt-secrets

The goal for this project was to find as many public-available JWT secrets as possible to help developers and DevOpses identify it by traffic analysis at the Wallarm NGWAF level. 

For now (10/02/2020) the list consists of 3502

We focused on Google search and GitHub dorks by using mainly two query patterns: 
1. ```jwt example +TECHNOLOGY``` where the ```TECHNOLOGY``` is the language itself like PHP, Ruby, Rails, or framework like ExpressJS, Struts of Flask.
1. Google BigQuery search based on 3M GitHub projects

This repository is automatically connected with the JWT heartbreaker Burp extension (see: https://lab.wallarm.com/meet-jwt-heartbreaker-a-burp-extension-that-finds-thousands-weak-secrets-automatically/)
