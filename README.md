# kobo

This is a helm Chart for [Kobo Toolbox](https://www.kobotoolbox.org/).

## How to run

### Prerequisites

* A Kubernetes cluster
* [Helm](https://helm.sh/)

### Limitations

* The built-in nginx container only supports http for now. It is expected that https support will typically be handled at the ingress level
* This setup requires the availability of 3 subdomains under the same root domain (just like `kobo-install`)

### Setup

Refer to `values.yaml` for details of all the variables that can be overridden, and create your own overrides in a separate file, e.g. `my-values.yaml`.

In particular you will need to setup a number of secrets, as well as provide a valid public domain name that the application will be reachable on.

Then, install the helm release as usual.

```sh
# Clone the project
git clone https://github.com/one-acre-fund/kobo && cd kobo

# Install chart dependencies
helm dependency update deployment/kobo

# Override desired values in your own override file
vi my-values.yaml

# Install chart
helm install --values my-values.yaml kobo deployment/kobo
```

You should see a bunch of new pods popping up:

```sh
$ kubectl get pods
oaf-kobo-kobo-694bb8449d-55gjl                                 4/4     Running     0          13m
oaf-kobo-mongodb-5fc744955b-z76j9                              1/1     Running     0          125m
oaf-kobo-postgresql-0                                          1/1     Running     0          125m
oaf-kobo-rediscache-master-0                                   1/1     Running     0          125m
oaf-kobo-redismain-master-0                                    1/1     Running     0          125m
```

## References

* [Kobo Toolbox](https://www.kobotoolbox.org/)
* [kobo-docker](https://github.com/kobotoolbox/kobo-docker)
