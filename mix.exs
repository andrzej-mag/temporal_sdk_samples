defmodule TemporalSdkSamples.MixProject do
  use Mix.Project

  @source_url "https://github.com/andrzej-mag/temporal_sdk_samples"

  @elixir_deps [
    {:dialyxir, "~> 1.4.0", only: [:dev, :test], runtime: false},
    {:ex_doc, "~> 0.39.0", only: :dev, runtime: false}
  ]

  @shared_deps_opts []

  def project,
    do: [
      app: app_name!(),
      version: version(),
      elixir: "~> 1.17",
      aliases: aliases(),
      deps: deps(@elixir_deps, @shared_deps_opts),
      erlc_options: rebar_key!(:erl_opts),
      test_paths: ["test_ex"],
      deps_path: "_deps",
      # hex.pm package metadata
      description: "Temporal Erlang and Elixir SDK samples. (dummy hexdocs-only package)",
      name: app_name!(),
      source_url: @source_url,
      package: package(),
      docs: docs()
    ]

  def application,
    do: [
      extra_applications: [:logger]
    ]

  defp version, do: app_key!(:vsn) |> to_string

  defp version_tag(_), do: IO.puts("v#{version()}")

  defp aliases,
    do: [
      version_tag: &version_tag/1
    ]

  defp package,
    do: [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      files: ["LICENSE*", "README.md", "CHANGELOG.md"]
    ]

  defp docs,
    do: [
      output: "_doc",
      extras: ["CHANGELOG.md", "README.md": [title: "Readme"]],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{version()}",
      formatters: ["html"],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      groups_for_modules: groups_for_modules()
    ]

  defp groups_for_modules,
    do: [
      "Elixir": [
        ActivityHeartbeat,
        HelloWorld,
        PayloadConverter,
        QueryParallelHandler,
        RateLimiter,
        Saga,
        SignalParallelHandler,
        SignalSimple
      ],
      Erlang: [
        :activity_heartbeat,
        :echo_activity,
        :hello_world,
        :payload_converter,
        :query_parallel_handler,
        :rate_limiter,
        :saga,
        :signal_parallel_handler,
        :signal_simple,
        :worker_benchmark
      ]
    ]

  # -------------------------------------------------------------------------------------------------
  # Erlang config helpers

  defp rebar_config! do
    {:ok, rebar_config} = :file.consult("rebar.config")
    rebar_config
  end

  defp rebar_key!(key), do: Keyword.fetch!(rebar_config!(), key)

  defp app_src! do
    {:ok, [{:application, name, meta}]} = :file.consult("src/temporal_sdk_samples.app.src")
    {name, meta}
  end

  defp app_key!(key) do
    {_name, meta} = app_src!()
    Keyword.fetch!(meta, key)
  end

  defp app_name! do
    {name, _meta} = app_src!()
    name
  end

  defp deps(elixir_deps, shared_deps_opts) do
    map_fun =
      fn
        {dep, ver} ->
          case Keyword.fetch(shared_deps_opts, dep) do
            {:ok, ex_opts} -> {dep, to_string(ver), ex_opts}
            :error -> {dep, to_string(ver)}
          end

        {dep, ver, opts} ->
          case Keyword.fetch(shared_deps_opts, dep) do
            {:ok, ex_opts} -> {dep, to_string(ver), ex_opts}
            :error -> {dep, to_string(ver), opts}
          end
      end

    rebar_key!(:deps)
    |> Enum.map(map_fun)
    |> Enum.concat(elixir_deps)
  end
end
