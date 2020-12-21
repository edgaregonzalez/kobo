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

Refer to `values.yaml` for details of all the variables that can be overridden.

In particular you will need to setup a number of secrets.

```sh
helm install --values my-values.yaml kobo deployment/kobo
```

## References

* [Kobo Toolbox](https://www.kobotoolbox.org/)
* [kobo-docker](https://github.com/kobotoolbox/kobo-docker)
