import Config

config :temporal_sdk,
  clusters: [
    cluster_1: [
      activities: [[task_queue: "default"]],
      workflows: [[task_queue: "default"]]
    ],
    cluster_1_enc: [
      client: [
        grpc_opts: [
          converter:
            {:temporal_sdk_proto_converter, [{:payload_converter_codec, [:compressed], [:safe]}]}
        ]
      ],
      activities: [[task_queue: "encrypted"]],
      workflows: [[task_queue: "encrypted"]]
    ]
  ]

config :opentelemetry,
  span_processor: :batch,
  traces_exporter: :otlp,
  resource: [service: %{name: "temporal_sdk_samples"}]

config :opentelemetry_exporter,
  # otlp_protocol: :grpc,
  # otlp_endpoint: "http://127.0.0.1:4317",
  otlp_protocol: :http_protobuf,
  otlp_endpoint: "http://127.0.0.1:4318"
