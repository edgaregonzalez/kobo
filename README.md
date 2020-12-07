# kobo

This is a helm Chart for [Kobo Toolbox](https://www.kobotoolbox.org/).

## How to run

### Prerequisites

* A Kubernetes cluster
* [Helm](https://helm.sh/)

### Setup

Refer to `values.yaml` for details of all the variables that can be overridden.

In particular you will need to setup a number of secrets.

```sh
echo  > my-values.yaml
helm install --values my-values.yaml kobo deployment/kobo
```
## References

* [Kobo Toolbox](https://www.kobotoolbox.org/)
* [kobo-docker](https://github.com/kobotoolbox/kobo-docker)
