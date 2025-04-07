# real-time-flink-analytics
Use flink for streaming analytics through orderbook data generator from repo: https://github.com/AdrienLibert/orderbook
The above repo has been built together with @[AdrienLibert](https://github.com/AdrienLibert)

# Install

## Dependencies

Kafka
```
make helm
make start_kafka
```


Trade & Orderbook generator [orderbook](https://github.com/AdrienLibert/orderbook). Assuming the repo is cloned in the same parent folder:
```
make build_orderbook
make start_orderbook
```