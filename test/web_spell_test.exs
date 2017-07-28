defmodule TestClient do
  use WebSpell
end

defmodule WebSpellTest do
  use ExUnit.Case

  setup do
    TestClient.start_link
    :ok
  end

  test "call_stubbed_request! errors when no matching stub found" do
    TestClient.stub_request(
      %WebSpell.Request{method: :get, url: "/wrong"},
      %WebSpell.Response{status: 500, body: nil})

    assert_raise RuntimeError, fn ->
      TestClient.call_stubbed_request!(%WebSpell.Request{method: :get, url: "/"})
    end
  end

  test "call_stubbed_request! returns the response to the matching request" do
    TestClient.stub_request(
      %WebSpell.Request{method: :get, url: "/"},
      %WebSpell.Response{status: 201, body: "success!"})

    response = TestClient.call_stubbed_request!(%WebSpell.Request{method: :get, url: "/"})

    assert response == %WebSpell.Response{status: 201, body: "success!"}
  end

  test "received_request returns matching recorded request" do
    TestClient.stub_request(
      %WebSpell.Request{method: :get, url: "/"},
      %WebSpell.Response{status: 201, body: "success!"})

    TestClient.call_stubbed_request!(%WebSpell.Request{method: :get, url: "/"})

    assert TestClient.received_request(%WebSpell.Request{method: :get, url: "/"})
  end

  test "received_request returns nil if no matching request recorded" do
    TestClient.stub_request(
      %WebSpell.Request{method: :get, url: "/"},
      %WebSpell.Response{status: 201, body: "success!"})

    TestClient.call_stubbed_request!(%WebSpell.Request{method: :get, url: "/"})

    refute TestClient.received_request(%WebSpell.Request{method: :get, url: "/wrong"})
  end

  test "received_no_request returns true if no matching request recorded" do
    TestClient.stub_request(
      %WebSpell.Request{method: :get, url: "/"},
      %WebSpell.Response{status: 201, body: "success!"})

    TestClient.call_stubbed_request!(%WebSpell.Request{method: :get, url: "/"})

    assert TestClient.received_no_request(%WebSpell.Request{method: :get, url: "/wrong"})
  end

  test "received_no_request returns nil if  matching request recorded" do
    TestClient.stub_request(
      %WebSpell.Request{method: :get, url: "/"},
      %WebSpell.Response{status: 201, body: "success!"})

    TestClient.call_stubbed_request!(%WebSpell.Request{method: :get, url: "/"})

    refute TestClient.received_no_request(%WebSpell.Request{method: :get, url: "/"})
  end
end
