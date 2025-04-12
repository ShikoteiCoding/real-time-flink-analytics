helm:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add flink-operator-repo https://downloads.apache.org/flink/flink-kubernetes-operator-1.10.0/

clear_helm:
	helm repo remove flink-operator-repo
	helm repo remove bitnami

build_flink:
	docker build -t local/flink-jobs -f Dockerfile flink/

start_kafka:
	helm install bitnami bitnami/kafka --version 31.0.0 -n orderbook --create-namespace -f helm/kafka-values.yaml

stop_kafka:
	helm uninstall --ignore-not-found bitnami

build_deps: # TODO: change to main branch after orderbook repo is clean
	docker build https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose:src/kafka_init -t local/kafka-init
	docker build https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose:src/orderbook -t local/orderbook
	docker build https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose:src/traderpool -t local/traderpool

start_flink_operator:
	helm install flink-kubernetes-operator flink-operator-repo/flink-kubernetes-operator --namespace analytics --create-namespace --version 1.10.0 -f helm/flink-operator-values.yaml

stop_flink_operator:
	helm uninstall --ignore-not-found flink-kubernetes-operator -n analytics
	kubectl delete crd flinkclusters.flinkoperator.k8s.io --ignore-not-found

start_deps: start_kafka start_flink_operator
	helm install orderbook https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose:chart.zip --namespace orderbook -f helm/orderbook-values.yaml
	kubectl create secret generic postgres --from-literal=password=postgres --from-literal=postgres-password=postgres --dry-run -o yaml | kubectl apply -f -
	helm install postgres bitnami/postgresql --version 16.5.6 -n analytics --create-namespace -f helm/postgres-values.yaml

stop_deps: stop_kafka, stop_flink_operator
	helm uninstall --ignore-not-found orderbook --namespace orderbook
	helm uninstall --ignore-not-found postgres -n analytics
	kubectl delete --ignore-not-found pvc data-postgres-postgresql-0 -n analytics
	kubectl delete --ignore-not-found secret postgres


#	curl -LO "https://github.com/AdrienLibert/orderbook.git#clean-repo-for-chart-only-purpose" --output chart.zip

try:
	curl -L -H "Accept: application/vnd.github.VERSION.raw" https://api.github.com/repos/AdrienLibert/orderbook/contents/chart.zip\?ref\=clean-repo-for-chart-only-purpose --output chart.zip
	unzip chart.zip -d .

test:
	helm install orderbook chartorderbook.zip