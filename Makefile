helm:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add flink-operator-repo https://downloads.apache.org/flink/flink-kubernetes-operator-1.10.0/
	helm repo update

clear_helm:
	helm repo remove flink-operator-repo
	helm repo remove bitnami

build_flink:
	docker build -t local/flink-jobs -f flink/Dockerfile flink/

start_kafka:
	helm upgrade --install bitnami bitnami/kafka --version 31.0.0 -n orderbook --create-namespace -f helm/kafka-values.yaml

stop_kafka:
	helm uninstall --ignore-not-found bitnami

build_orderbook:
	sh ../orderbook/build.sh

start_orderbook:
	helm install orderbook ../orderbook/chart --namespace orderbook -f helm/orderbook-values.yaml

stop_orderbook:
	helm uninstall --ignore-not-found orderbook --namespace orderbook

start_flink_operator:
	helm upgrade --install flink-kubernetes-operator flink-operator-repo/flink-kubernetes-operator --namespace analytics --create-namespace --version 1.10.0 -f helm/flink-operator-values.yaml

stop_flink_operator:
	helm uninstall --ignore-not-found flink-kubernetes-operator -n analytics
	kubectl delete crd flinkclusters.flinkoperator.k8s.io --ignore-not-found