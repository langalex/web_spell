# add to your http client stub module by calling `use WebSpell`
defmodule WebSpell do
  defmacro __using__(opts) do
    server_name = opts[:server_name] || :web_spell

    quote do
      use GenServer

      # call this method in your test before setting up any stubs
      def start_link do
        {:ok, pid} = GenServer.start_link(__MODULE__, :ok, [])
        Process.register(pid, unquote(server_name))
      end
      
      # call this in your test to set up a stubbed http request/response
      def stub_request(%WebSpell.Request{} = request, %WebSpell.Response{} = response) do
        server = Process.whereis(unquote(server_name))
        GenServer.cast(server, {:stub_request, request, response})
      end

      # forward any http calls in your http client module to this method
      def call_stubbed_request!(%WebSpell.Request{} = request) do
        server = Process.whereis(unquote(server_name))
        case GenServer.call(server, {:call_stubbed_request, request}) do
          :missing_stub -> raise("missing stub for #{inspect request}")
          response -> response
        end
      end

      # use this function in test assertions, i.e. assert MyClient.received_request(…)
      def received_request(%WebSpell.Request{} = request) do
        recorded_request = find_recorded_request(request)
        if recorded_request do
          recorded_request
        else
          IO.puts("\nExpected request #{inspect request} to have been made but wasn't.")
          print_recorded_requests()
          nil
        end
      end

      # use this function in test assertions, i.e. assert MyClient.received_no_request(…)
      def received_no_request(%WebSpell.Request{} = request) do
        recorded_request = find_recorded_request(request)
        if recorded_request do
          IO.puts("\nExpected request #{inspect request} to not have been made but was.")
          print_recorded_requests()
          nil
        else
          true
        end
      end

      # genserver
      
      def init(:ok) do
        {:ok, %{request_stubs: [], recorded_requests: []}}
      end  

      def handle_cast({:stub_request, request, response}, %{request_stubs: request_stubs, recorded_requests: recorded_requests}) do
        {
          :noreply, 
          %{request_stubs: request_stubs ++ [%WebSpell.RequestStub{request: request, response: response}],
            recorded_requests: recorded_requests}
        }
      end

      def handle_call({:call_stubbed_request, request}, _from, %{request_stubs: request_stubs, recorded_requests: recorded_requests = state}) do
        stub = Enum.find(request_stubs, fn stub ->
          stub.request.url == request.url && stub.request.method == request.method
        end)
        if stub do
          {
            :reply, 
            stub.response, 
            %{request_stubs: request_stubs,
              recorded_requests: recorded_requests ++ [request]}
          }
        else
          IO.puts "\nNo stub found for request #{inspect request}."
          IO.puts "Stubbed requests:"
          for(stub <- request_stubs) do
            IO.inspect stub.request
          end
          {:reply, :missing_stub, state}
        end
      end

      def handle_call({:fetch_recorded_requests}, _from, %{recorded_requests: recorded_requests} = state) do
        {:reply, recorded_requests, state}
      end
      
      # /genserver

      defp print_recorded_requests do
        IO.puts("Requests made:")
        for(request <- recorded_requests()) do
          IO.inspect(request)
        end
      end

      defp find_recorded_request(request) do
        Enum.find(recorded_requests(), fn recorded_request ->
          recorded_request.method == request.method && recorded_request.url == request.url
        end)
      end

      defp recorded_requests do
        server = Process.whereis(unquote(server_name))
        GenServer.call(server, {:fetch_recorded_requests})
      end
    end
  end
end