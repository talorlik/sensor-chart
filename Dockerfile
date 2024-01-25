FROM debian:stable-slim AS build-env
ARG VERSION
RUN echo ${VERSION}
RUN mkdir -p sensor/${VERSION}

COPY Sensor sensor/${VERSION}/sensor
COPY Sensor.signature sensor/${VERSION}/sensor.signature
COPY SensorLauncher sensor/sensor_launcher
COPY SensorLauncher.signature sensor/sensor_launcher.signature
COPY Config.bin sensor/

FROM debian:stable-slim
ENV DEBIAN_PRIORITY=critical
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux
RUN apt-get update && apt-get install -y ca-certificates curl gnupg apt-transport-https apt-utils procps uuid-runtime vim \
    && rm -rf /var/lib/apt/lists/* \
    && echo $(uuidgen | tr -d "-") > /etc/machine-id
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor --yes --batch --quiet | tee /usr/share/keyrings/kubernetes-archive-keyring.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && apt-get install -y kubectl
COPY --from=build-env /sensor/ /opt/sensor/
WORKDIR /opt/sensor/
ENV SENSOR_PLATFORM docker
ENV SENSOR_DISABLE_UPDATES true
ENV SENSOR_LOG_LEVEL info
ENV SENSOR_SENSOR_CUSTOM_LABELS ""
CMD /opt/sensor/sensor_launcher
