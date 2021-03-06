defmodule Hyperledger.ModelTest.Issue do
  use HyperledgerTest.Case
  use Ecto.Model
  
  alias Hyperledger.Repo
  alias Hyperledger.Issue
  alias Hyperledger.Ledger
  
  setup do
    Ledger.create(
      hash: "abc",
      public_key: "123",
      primary_account_public_key: "cde")
    :ok
  end
  
  test "`create` inserts the record into the db" do
    uuid = UUID.uuid4
    Issue.create(
      uuid: uuid,
      ledger_hash: "abc",
      amount: 100)

    assert Repo.get(Issue, UUID.info(uuid)[:binary]) != nil
  end

  test "`create` also modifies the balance of the primary wallet" do
    Issue.create(
      uuid: UUID.uuid4,
      ledger_hash: "abc",
      amount: 100)

    l = Repo.get(Ledger, "abc")
    [a] = Repo.all assoc(l, :primary_account)
    assert a.balance == 100
  end
end