# Cluster API Canonical Kubernetes Helm Charts

Helm Charts to deploy Canonical Kubernetes clusters using [Cluster API](https://github.com/kubernetes-sigs/cluster-api/blob/master/README.md).
Cluster API should use Bootstrap and Control plane providers from [Cluster API Canonical Kubernetes](https://github.com/canonical/cluster-api-k8s/)


# Available helm charts

## openstack-ck8s-cluster

Supports deployment of Canonical Kubernetes clusters on openstack infrastructure.
The chart is designed to work with [OpenStack Magnum project](https://docs.openstack.org/magnum/latest/) using driver [magnum-capi-helm](https://docs.openstack.org/magnum-capi-helm/latest/)

Once deployed, user will get a canonical k8s cluster on top of openstack instances with ck8s default features enabled CNI cilium, Local filestorage, Ingress as well as cluster addons like OpenStack CCM and CSI Cinder.
Users can use OpenStack Cinder as storage backend for k8s and OpenStack Loadbalancer as external Loadbalancer for k8s.

### Cluster addon's supported

* OpenStack Cloud Controller Manager
* CSI Cinder


### Future work

* Add support for kubernetes dashboard
* Add support to enable/disable Ingress. Currently Ingress is enabled by default.
  It is not possible to enable/disable features on Canonical K8S due to bug
  https://github.com/canonical/cluster-api-k8s/issues/170
* Add support for CSI Manila
* Add support for monitoring
* Add support for deploying CNI other than cillium
  Depends on https://github.com/canonical/cluster-api-k8s/issues/170, https://github.com/canonical/cluster-api-k8s/issues/169
* Provision to add Registry mirrors


### Design considerations in writing Helm charts

* For cluster addons, use official k8s-sig cluster add-on provider [cluster-api-addon-provider-helm](https://github.com/kubernetes-sigs/cluster-api-addon-provider-helm)
  In case if manifests need to be created as part of addons, use [cluster resource set](https://github.com/kubernetes-sigs/cluster-api/blob/main/docs/proposals/20200220-cluster-resource-set.md)
  For example, openstack-cloud-controller-manager charm expects a secret to be injected in desired cluster with cloud credentials. This is acheived via cluster resource set since the openstack-cloud-controller-manager didnot support this

  Alternative solutions available: [cluster-api-addon-provider](https://github.com/azimuth-cloud/cluster-api-addon-provider) supports Helm Charts and Manifests as CRD

* Upstream chart [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler) requires some changes to pass on dynamic values within the parent helm chart openstack-ck8s-cluster. To achieve this, cluster-autoscaler is added as git subtree and modifications are done on top of it.

  Commands used to add upstream repo autoscaler with tag cluster-autoscaler-chart-9.47.0:

  ```
  git remote add autoscaler-remote https://github.com/kubernetes/autoscaler.git
  git fetch autoscaler-remote
  # git branch temp_autoscaler_9.47.0 autoscaler-remote/cluster-autoscaler-chart-9.47.0
  git branch temp_autoscaler_9.47.0 cluster-autoscaler-chart-9.47.0
  git checkout -f temp_autoscaler_9.47.0
  git subtree split --prefix=charts/cluster-autoscaler -b temp_autoscaler_chart_9.47.0
  git checkout -f autoscaler
  git subtree add --prefix=charts/openstack-ck8s-cluster/charts/cluster-autoscaler temp_autoscaler_chart_9.47.0 --squash
  ```
