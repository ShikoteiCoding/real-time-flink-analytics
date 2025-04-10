helm:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add flink-operator-repo https://downloads.apache.org/flink/flink-kubernetes-operator-1.10.0/

clear_helm:
	helm repo remove flink-operator-repo
	helm repo remove bitnami

build_flink:
	docker build -t local/flink-jobs -f Dockerfile flink/

start_kafka:
	helm upgrade --install bitnami bitnami/kafka --version 31.0.0 -n orderbook --create-namespace -f helm/kafka-values.yaml

stop_kafka:
	helm uninstall --ignore-not-found bitnami

build_deps: # TODO: change to main branch after orderbook repo is clean
	docker build https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose:src/kafka_init -t local/kafka-init
	docker build https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose:src/orderbook -t local/orderbook
	docker build https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose:src/traderpool -t local/traderpool

start_flink_operator:
	helm upgrade --install flink-kubernetes-operator flink-operator-repo/flink-kubernetes-operator --namespace analytics --create-namespace --version 1.10.0 -f helm/flink-operator-values.yaml

stop_flink_operator:
	helm uninstall --ignore-not-found flink-kubernetes-operator -n analytics
	kubectl delete crd flinkclusters.flinkoperator.k8s.io --ignore-not-found

start_deps: start_kafka start_flink_operator
	helm upgrade --install orderbook https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose --namespace orderbook -f helm/orderbook-values.yaml

stop_deps: stop_kafka, stop_flink_operator
	helm uninstall --ignore-not-found orderbook --namespace orderbook