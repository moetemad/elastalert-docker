# Elastalert Docker image

Docker image for [Elastalert](https://github.com/Yelp/elastalert).

## Running

### Image

The image is available at `hacknowledge/elastalert`.

```bash
$ docker pull hacknowledge/elastalert:latest
$ docker run hacknowledge/elastalert ARGUMENTS
```

The arguments are passed directly to Elastalert, and are documented in the official [documentation](https://elastalert.readthedocs.io/en/latest/elastalert.html?highlight=arguments#running-elastalert). 

### Requirements

A few things to keep in mind:

- Any file you pass in the command line arguments must be mounted inside the container.

- The ElasticSearch host you set in the Elastalert configuration must be reachable from inside the container.

- If it is the first time you are runnning Elastalert against your cluster, you need to create its status index in elasticsearch prior to running it (see [docs](https://elastalert.readthedocs.io/en/latest/running_elastalert.html#setting-up-elasticsearch)). This can be done independently from the Docker image, or using:

```
docker run --rm --entrypoint elastalert-create-index hacknowledge/elastalert --host ES_IP --port 9200 --index elastalert_status --no-ssl --username " " --password " " --url-prefix "" --old-index ""
```

### Example usage

```bash
$ docker run \
    --restart=always \
    --name elastalert \
    -v $(pwd)/rules:/opt/elastalert/rules \
    -v $(pwd)/elastalert.yml:/opt/elastalert/config.yaml \
    -e TZ=Europe/Zurich \
    hacknowledge/elastalert --config /opt/elastalert/config.yaml --verbose
```

Or with Docker compose:


```yaml
version: '3'
services:
  elastalert:
    image: hacknowledge/elastalert
    container_name: elastalert
    restart: always
    volumes:
    - /opt/elastalert/rules:/opt/elastalert/rules
    - ./elastalert.yml:/opt/elastalert/config.yaml
    environment:
    - TZ=Europe/Zurich
    command: --config /opt/elastalert/config.yaml --verbose
```

Sample `config.yaml` file (see [full documentation](https://elastalert.readthedocs.io/en/latest/ruletypes.html#common-configuration-options)):


```yaml
es_host: 192.168.1.21
es_port: 9200

writeback_index: elastalert_status
rules_folder: /opt/elastalert/rules

run_every:
  seconds: 5

timestamp_field: timestamp
timestamp_type: custom
timestamp_format: "%Y-%m-%d %H:%M:%S.%f"
timestamp_format_expr: 'ts[:23] + ts[26:]'


http_post_url: https://yourcorp.tld/alerts

buffer_time:
  minutes: 15
```


## Building 

```
docker build . -t elastalert
```

If you need a specific version of Elastalert:

```
docker build --build-arg ELASTALERT_VERSION=0.1.38 . -t elastalert
```
