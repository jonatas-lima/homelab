deployment:
  replicas: 3

podDisruptionBudget:
  enabled: true
  minAvailable: 1

ingressClass:  # @schema additionalProperties: false
  enabled: false

gateway:
  # -- When providers.kubernetesGateway.enabled, deploy a default gateway
  enabled: true
  # -- Set a custom name to gateway

gatewayClass:  # @schema additionalProperties: false
  enabled: true
  # -- Set a custom name to GatewayClass
  name: "internal"

ingressRoute:
  dashboard:
    # -- Create an IngressRoute for the dashboard
    enabled: false
    # -- Additional ingressRoute annotations (e.g. for kubernetes.io/ingress.class)
    annotations: {}
    # -- Additional ingressRoute labels (e.g. for filtering IngressRoute by custom labels)
    labels: {}
    # -- The router match rule used for the dashboard ingressRoute
    matchRule: PathPrefix(`/dashboard`) || PathPrefix(`/api`)
    # -- The internal service used for the dashboard ingressRoute
    services:
      - name: api@internal
        kind: TraefikService
    # -- Specify the allowed entrypoints to use for the dashboard ingress route, (e.g. traefik, web, websecure).
    # By default, it's using traefik entrypoint, which is not exposed.
    # /!\ Do not expose your dashboard without any protection over the internet /!\
    entryPoints: ["traefik"]
    # -- Additional ingressRoute middlewares (e.g. for authentication)
    middlewares: []
    # -- TLS options (e.g. secret containing certificate)
    tls: {}
  healthcheck:
    # -- Create an IngressRoute for the healthcheck probe
    enabled: false
    # -- Additional ingressRoute annotations (e.g. for kubernetes.io/ingress.class)
    annotations: {}
    # -- Additional ingressRoute labels (e.g. for filtering IngressRoute by custom labels)
    labels: {}
    # -- The router match rule used for the healthcheck ingressRoute
    matchRule: PathPrefix(`/ping`)
    # -- The internal service used for the healthcheck ingressRoute
    services:
      - name: ping@internal
        kind: TraefikService
    # -- Specify the allowed entrypoints to use for the healthcheck ingress route, (e.g. traefik, web, websecure).
    # By default, it's using traefik entrypoint, which is not exposed.
    entryPoints: ["traefik"]
    # -- Additional ingressRoute middlewares (e.g. for authentication)
    middlewares: []
    # -- TLS options (e.g. secret containing certificate)
    tls: {}

providers:  # @schema additionalProperties: false
  kubernetesCRD:
    enabled: false

  kubernetesIngress:
    enabled: false

  kubernetesGateway:
    enabled: true

metrics:
  # -- Enable metrics for internal resources. Default: false
  addInternals: false

  ## Prometheus is enabled by default.
  ## It can be disabled by setting "prometheus: null"
  prometheus:
    # -- Entry point used to expose metrics.
    entryPoint: metrics
    # -- Enable metrics on entry points. Default: true
    addEntryPointsLabels:  # @schema type:[boolean, null]
    # -- Enable metrics on routers. Default: false
    addRoutersLabels:  # @schema type:[boolean, null]
    # -- Enable metrics on services. Default: true
    addServicesLabels:  # @schema type:[boolean, null]
    # -- Buckets for latency metrics. Default="0.1,0.3,1.2,5.0"
    buckets: ""
    # -- When manualRouting is true, it disables the default internal router in
    ## order to allow creating a custom router for prometheus@internal service.
    manualRouting: false
    # -- Add HTTP header labels to metrics. See EXAMPLES.md or upstream doc for usage.
    headerLabels: {}  # @schema type:[object, null]
    service:
      # -- Create a dedicated metrics service to use with ServiceMonitor
      enabled: false
      labels: {}
      annotations: {}
    # -- When set to true, it won't check if Prometheus Operator CRDs are deployed
    disableAPICheck:  # @schema type:[boolean, null]
    serviceMonitor:
      # -- Enable optional CR for Prometheus Operator. See EXAMPLES.md for more details.
      enabled: false
      metricRelabelings: []
      relabelings: []
      jobLabel: ""
      interval: ""
      honorLabels: false
      scrapeTimeout: ""
      honorTimestamps: false
      enableHttp2: false
      followRedirects: false
      additionalLabels: {}
      namespace: ""
      namespaceSelector: {}
    prometheusRule:
      # -- Enable optional CR for Prometheus Operator. See EXAMPLES.md for more details.
      enabled: false
      additionalLabels: {}
      namespace: ""

  otlp:
    # -- Set to true in order to enable the OpenTelemetry metrics
    enabled: false
    # -- Enable metrics on entry points. Default: true
    addEntryPointsLabels:  # @schema type:[boolean, null]
    # -- Enable metrics on routers. Default: false
    addRoutersLabels:  # @schema type:[boolean, null]
    # -- Enable metrics on services. Default: true
    addServicesLabels:  # @schema type:[boolean, null]
    # -- Explicit boundaries for Histogram data points. Default: [.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10]
    explicitBoundaries: []
    # -- Interval at which metrics are sent to the OpenTelemetry Collector. Default: 10s
    pushInterval: ""
    http:
      # -- Set to true in order to send metrics to the OpenTelemetry Collector using HTTP.
      enabled: false
      # -- Format: <scheme>://<host>:<port><path>. Default: http://localhost:4318/v1/metrics
      endpoint: ""
      # -- Additional headers sent with metrics by the reporter to the OpenTelemetry Collector.
      headers: {}
      ## Defines the TLS configuration used by the reporter to send metrics to the OpenTelemetry Collector.
      tls:
        # -- The path to the certificate authority, it defaults to the system bundle.
        ca: ""
        # -- The path to the public certificate. When using this option, setting the key option is required.
        cert: ""
        # -- The path to the private key. When using this option, setting the cert option is required.
        key: ""
        # -- When set to true, the TLS connection accepts any certificate presented by the server regardless of the hostnames it covers.
        insecureSkipVerify:  # @schema type:[boolean, null]
    grpc:
      # -- Set to true in order to send metrics to the OpenTelemetry Collector using gRPC
      enabled: false
      # -- Format: <scheme>://<host>:<port><path>. Default: http://localhost:4318/v1/metrics
      endpoint: ""
      # -- Allows reporter to send metrics to the OpenTelemetry Collector without using a secured protocol.
      insecure: false
      ## Defines the TLS configuration used by the reporter to send metrics to the OpenTelemetry Collector.
      tls:
        # -- The path to the certificate authority, it defaults to the system bundle.
        ca: ""
        # -- The path to the public certificate. When using this option, setting the key option is required.
        cert: ""
        # -- The path to the private key. When using this option, setting the cert option is required.
        key: ""
        # -- When set to true, the TLS connection accepts any certificate presented by the server regardless of the hostnames it covers.
        insecureSkipVerify: false

## Tracing
# -- https://doc.traefik.io/traefik/observability/tracing/overview/
tracing:  # @schema additionalProperties: false
  # -- Enables tracing for internal resources. Default: false.
  addInternals: false
  # -- Service name used in selected backend. Default: traefik.
  serviceName:  # @schema type:[string, null]
  # -- Defines additional resource attributes to be sent to the collector.
  resourceAttributes: {}
  # -- Defines the list of request headers to add as attributes. It applies to client and server kind spans.
  capturedRequestHeaders: []
  # -- Defines the list of response headers to add as attributes. It applies to client and server kind spans.
  capturedResponseHeaders: []
  # -- By default, all query parameters are redacted. Defines the list of query parameters to not redact.
  safeQueryParams: []
  # -- The proportion of requests to trace, specified between 0.0 and 1.0. Default: 1.0.
  sampleRate:  # @schema type:[number, null]; minimum:0; maximum:1
  otlp:
    # -- See https://doc.traefik.io/traefik/v3.0/observability/tracing/opentelemetry/
    enabled: false
    http:
      # -- Set to true in order to send metrics to the OpenTelemetry Collector using HTTP.
      enabled: false
      # -- Format: <scheme>://<host>:<port><path>. Default: http://localhost:4318/v1/metrics
      endpoint: ""
      # -- Additional headers sent with metrics by the reporter to the OpenTelemetry Collector.
      headers: {}
      ## Defines the TLS configuration used by the reporter to send metrics to the OpenTelemetry Collector.
      tls:
        # -- The path to the certificate authority, it defaults to the system bundle.
        ca: ""
        # -- The path to the public certificate. When using this option, setting the key option is required.
        cert: ""
        # -- The path to the private key. When using this option, setting the cert option is required.
        key: ""
        # -- When set to true, the TLS connection accepts any certificate presented by the server regardless of the hostnames it covers.
        insecureSkipVerify: false
    grpc:
      # -- Set to true in order to send metrics to the OpenTelemetry Collector using gRPC
      enabled: false
      # -- Format: <scheme>://<host>:<port><path>. Default: http://localhost:4318/v1/metrics
      endpoint: ""
      # -- Allows reporter to send metrics to the OpenTelemetry Collector without using a secured protocol.
      insecure: false
      ## Defines the TLS configuration used by the reporter to send metrics to the OpenTelemetry Collector.
      tls:
        # -- The path to the certificate authority, it defaults to the system bundle.
        ca: ""
        # -- The path to the public certificate. When using this option, setting the key option is required.
        cert: ""
        # -- The path to the private key. When using this option, setting the cert option is required.
        key: ""
        # -- When set to true, the TLS connection accepts any certificate presented by the server regardless of the hostnames it covers.
        insecureSkipVerify: false

# -- Global command arguments to be passed to all traefik's pods
globalArguments:
- "--global.checknewversion"
- "--global.sendanonymoususage"

# -- Additional arguments to be passed at Traefik's binary
# See [CLI Reference](https://docs.traefik.io/reference/static-configuration/cli/)
# Use curly braces to pass values: `helm install --set="additionalArguments={--providers.kubernetesingress.ingressclass=traefik-internal,--log.level=DEBUG}"`
additionalArguments: []
#  - "--providers.kubernetesingress.ingressclass=traefik-internal"
#  - "--log.level=DEBUG"

# -- Additional Environment variables to be passed to Traefik's binary
# @default -- See _values.yaml_
env: []

# -- Environment variables to be passed to Traefik's binary from configMaps or secrets
envFrom: []

ports:
  traefik:
    port: 8080
    # -- Use hostPort if set.
    hostPort:  # @schema type:[integer, null]; minimum:0
    # -- Use hostIP if set. If not set, Kubernetes will default to 0.0.0.0, which
    # means it's listening on all your interfaces and all your IPs. You may want
    # to set this value if you need traefik to listen on specific interface
    # only.
    hostIP:  # @schema type:[string, null]

    # Defines whether the port is exposed if service.type is LoadBalancer or
    # NodePort.
    #
    # -- You SHOULD NOT expose the traefik port on production deployments.
    # If you want to access it from outside your cluster,
    # use `kubectl port-forward` or create a secure ingress
    expose:
      default: false
    # -- The exposed port for this service
    exposedPort: 8080
    # -- The port protocol (TCP/UDP)
    protocol: TCP
  web:
    ## -- Enable this entrypoint as a default entrypoint. When a service doesn't explicitly set an entrypoint it will only use this entrypoint.
    # asDefault: true
    port: 8000
    # hostPort: 8000
    # containerPort: 8000
    expose:
      default: true
    exposedPort: 80
    ## -- Different target traefik port on the cluster, useful for IP type LB
    targetPort:  # @schema type:[string, integer, null]; minimum:0
    # The port protocol (TCP/UDP)
    protocol: TCP
    # -- See [upstream documentation](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport)
    nodePort:  # @schema type:[integer, null]; minimum:0
    redirections:
      # -- Port Redirections
      # Added in 2.2, one can make permanent redirects via entrypoints.
      # Same sets of parameters: to, scheme, permanent and priority.
      # https://docs.traefik.io/routing/entrypoints/#redirection
      entryPoint: {}
    forwardedHeaders:
      # -- Trust forwarded headers information (X-Forwarded-*).
      trustedIPs: []
      insecure: false
    proxyProtocol:
      # -- Enable the Proxy Protocol header parsing for the entry point
      trustedIPs: []
      insecure: false
    # -- Set transport settings for the entrypoint; see also
    # https://doc.traefik.io/traefik/routing/entrypoints/#transport
    transport:
      respondingTimeouts:
        readTimeout:   # @schema type:[string, integer, null]
        writeTimeout:  # @schema type:[string, integer, null]
        idleTimeout:   # @schema type:[string, integer, null]
      lifeCycle:
        requestAcceptGraceTimeout:  # @schema type:[string, integer, null]
        graceTimeOut:               # @schema type:[string, integer, null]
      keepAliveMaxRequests:         # @schema type:[integer, null]; minimum:0
      keepAliveMaxTime:             # @schema type:[string, integer, null]
  websecure:
    ## -- Enable this entrypoint as a default entrypoint. When a service doesn't explicitly set an entrypoint it will only use this entrypoint.
    # asDefault: true
    port: 8443
    hostPort:  # @schema type:[integer, null]; minimum:0
    containerPort:  # @schema type:[integer, null]; minimum:0
    expose:
      default: true
    exposedPort: 443
    ## -- Different target traefik port on the cluster, useful for IP type LB
    targetPort:  # @schema type:[string, integer, null]; minimum:0
    ## -- The port protocol (TCP/UDP)
    protocol: TCP
    # -- See [upstream documentation](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport)
    nodePort:  # @schema type:[integer, null]; minimum:0
    # -- See [upstream documentation](https://kubernetes.io/docs/concepts/services-networking/service/#application-protocol)
    appProtocol:  # @schema type:[string, null]
    # -- See [upstream documentation](https://doc.traefik.io/traefik/routing/entrypoints/#allowacmebypass)
    allowACMEByPass: false
    http3:
      ## -- Enable HTTP/3 on the entrypoint
      ## Enabling it will also enable http3 experimental feature
      ## https://doc.traefik.io/traefik/routing/entrypoints/#http3
      ## There are known limitations when trying to listen on same ports for
      ## TCP & UDP (Http3). There is a workaround in this chart using dual Service.
      ## https://github.com/kubernetes/kubernetes/issues/47249#issuecomment-587960741
      enabled: false
      advertisedPort:  # @schema type:[integer, null]; minimum:0
    forwardedHeaders:
        # -- Trust forwarded headers information (X-Forwarded-*).
      trustedIPs: []
      insecure: false
    proxyProtocol:
      # -- Enable the Proxy Protocol header parsing for the entry point
      trustedIPs: []
      insecure: false
    # -- See [upstream documentation](https://doc.traefik.io/traefik/routing/entrypoints/#transport)
    transport:
      respondingTimeouts:
        readTimeout:   # @schema type:[string, integer, null]
        writeTimeout:  # @schema type:[string, integer, null]
        idleTimeout:   # @schema type:[string, integer, null]
      lifeCycle:
        requestAcceptGraceTimeout:  # @schema type:[string, integer, null]
        graceTimeOut:               # @schema type:[string, integer, null]
      keepAliveMaxRequests:         # @schema type:[integer, null]; minimum:0
      keepAliveMaxTime:             # @schema type:[string, integer, null]
    # --  See [upstream documentation](https://doc.traefik.io/traefik/routing/entrypoints/#tls)
    tls:
      enabled: true
      options: ""
      certResolver: ""
      domains: []
    # -- One can apply Middlewares on an entrypoint
    # https://doc.traefik.io/traefik/middlewares/overview/
    # https://doc.traefik.io/traefik/routing/entrypoints/#middlewares
    # -- /!\ It introduces here a link between your static configuration and your dynamic configuration /!\
    # It follows the provider naming convention: https://doc.traefik.io/traefik/providers/overview/#provider-namespace
    #   - namespace-name1@kubernetescrd
    #   - namespace-name2@kubernetescrd
    middlewares: []
  metrics:
    # -- When using hostNetwork, use another port to avoid conflict with node exporter:
    # https://github.com/prometheus/prometheus/wiki/Default-port-allocations
    port: 9100
    # -- You may not want to expose the metrics port on production deployments.
    # If you want to access it from outside your cluster,
    # use `kubectl port-forward` or create a secure ingress
    expose:
      default: false
    # -- The exposed port for this service
    exposedPort: 9100
    # -- The port protocol (TCP/UDP)
    protocol: TCP

# -- TLS Options are created as [TLSOption CRDs](https://doc.traefik.io/traefik/https/tls/#tls-options)
# When using `labelSelector`, you'll need to set labels on tlsOption accordingly.
# See EXAMPLE.md for details.
tlsOptions: {}

# -- TLS Store are created as [TLSStore CRDs](https://doc.traefik.io/traefik/https/tls/#default-certificate). This is useful if you want to set a default certificate. See EXAMPLE.md for details.
tlsStore: {}

service:
  enabled: true
  ## -- Single service is using `MixedProtocolLBService` feature gate.
  ## -- When set to false, it will create two Service, one for TCP and one for UDP.
  single: true
  type: LoadBalancer
  # -- Additional annotations applied to both TCP and UDP services (e.g. for cloud provider specific config)
  annotations: {}
  # -- Additional annotations for TCP service only
  annotationsTCP: {}
  # -- Additional annotations for UDP service only
  annotationsUDP: {}
  # -- Additional service labels (e.g. for filtering Service by custom labels)
  labels: {}
  # -- Additional entries here will be added to the service spec.
  # -- Cannot contain type, selector or ports entries.
  spec:
    loadBalancerIP: "${load_balancer_ip}"

autoscaling:
  # -- Create HorizontalPodAutoscaler object.
  # See EXAMPLES.md for more details.
  enabled: false


# -- Certificates resolvers configuration.
# Ref: https://doc.traefik.io/traefik/https/acme/#certificate-resolvers
# See EXAMPLES.md for more details.
certificatesResolvers: {}
