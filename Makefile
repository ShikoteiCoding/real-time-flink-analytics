helm:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add flink-operator-repo https://downloads.apache.org/flink/flink-kubernetes-operator-1.10.0/
	helm repo add grafana https://grafana.github.io/helm-charts
	curl -L -H "Accept: application/vnd.github.VERSION.raw" https://api.github.com/repos/AdrienLibert/orderbook/contents/chart.zip\?ref\=clean-repo-for-chart-only-purpose --output chart.zip
	unzip chart.zip -d .

clear_helm:
	helm repo remove flink-operator-repo
	helm repo remove bitnami
	helm repo remove grafana

build_flink:
	docker build -t local/flink-jobs -f Dockerfile flink/

start_kafka:
	helm install bitnami bitnami/kafka --version 31.0.0 -n orderbook --create-namespace -f helm/kafka-values.yaml

stop_kafka:
	helm uninstall --ignore-not-found bitnami -n orderbook

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
	kubectl create secret generic postgres -n analytics --from-literal=password=postgres --from-literal=postgres-password=postgres --dry-run -o yaml | kubectl apply -f -
	helm install postgres bitnami/postgresql --version 16.5.6 -n analytics --create-namespace -f helm/postgres-values.yaml
	helm install grafana grafana/grafana --version 8.12.1 -n analytics --create-namespace
	helm install orderbook chart/ --namespace orderbook -f helm/orderbook-values.yaml

stop_deps: stop_kafka stop_flink_operator
	helm uninstall --ignore-not-found orderbook -n orderbook
	helm uninstall --ignore-not-found postgres -n analytics
	helm uninstall --ignore-not-found grafana -n analytics
	kubectl delete --ignore-not-found pvc data-postgres-postgresql-0 -n analytics
	kubectl delete --ignore-not-found secret postgres

start_infra:
	kubectl apply -f k8s/namespaces.yaml

start: start_infra
	kubectl apply -f k8s/candle-stick-job.yaml

stop:
	kubectl delete -f k8s/candle-stick-job.yaml