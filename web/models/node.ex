defmodule Hyperledger.Node do
  use Ecto.Model
  
  import Ecto.Query, only: [from: 2]
  
  alias Hyperledger.Repo
  alias Hyperledger.Node
  alias Hyperledger.PrepareConfirmation
  alias Hyperledger.CommitConfirmation
  
  schema "nodes" do
    field :url, :string
    field :public_key, :string

    timestamps
    
    has_many :prepare_confirmations, PrepareConfirmation
    has_many :commit_confirmations, CommitConfirmation
  end
  
  def self_id do
    [node] = Repo.all(from n in Node, where: n.url == ^System.get_env["NODE_URL"], select: n)
    node.id
  end
  
  def quorum do
    node_count = Repo.all(Node) |> Enum.count
    node_count - div(node_count - 1, 3)
  end
  
end
