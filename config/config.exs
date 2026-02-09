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
