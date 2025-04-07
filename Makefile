helm:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update

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