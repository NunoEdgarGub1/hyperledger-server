defmodule Hyperledger.LogEntryControllerTest do
  use HyperledgerTest.Case
    
  alias Hyperledger.Router
  alias Hyperledger.Repo
  alias Hyperledger.Node
  alias Hyperledger.LogEntry
  
  setup do
    System.put_env("NODE_URL", "http://localhost")
    %Node{id: 1, url: "http://localhost", public_key: "abc"}
    |> Repo.insert
    :ok
  end
  
  test "list log" do
    conn = call(Router, :get, "/log")
    assert conn.status == 200
  end
  
  test "refuse to create new log when primary" do
    body = %{logEntry: %{id: 1, view: 1, command: "ledger/create", data: sample_data}}
    conn = call(Router, :post, "/log", body,
      headers: [{"content-type", "application/json"}])

    assert conn.status == 403
    assert Repo.all(LogEntry) == []
  end
  
  test "accept log when replica" do
    System.put_env("NODE_URL", "http://localhost-2")
    %Node{id: 2, url: "http://localhost-2", public_key: "abc"}
    |> Repo.insert
    
    body = %{logEntry: %{id: 1, view: 1, command: "ledger/create", data: sample_data}}
    conn = call(Router, :post, "/log", body,
      headers: [{"content-type", "application/json"}])

    assert conn.status == 201
    assert Repo.all(LogEntry) |> Enum.count == 1
  end
  
  defp sample_data do
    {:ok, data} = %{ledger: %{hash: "123", publicKey: "abc", primaryAccountPublicKey: "def"}}
      |> Poison.encode
    data
  end
    
end
